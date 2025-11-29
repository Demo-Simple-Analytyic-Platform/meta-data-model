CREATE PROCEDURE deployment.all_datasets

    /* Input Parameters */
    @ip_is_debugging     BIT = 0,
    @ip_is_testing       BIT = 0,
    @ip_is_override      BIT = 0 /* Is set to 1 to override re-build procedure for ever table. */

AS DECLARE 
      
    /* Data Attributes */
    @id_model         CHAR(32) = (SELECT id_model FROM deployment.current_model),
    @id_dataset       CHAR(32),
    @nm_target_schema NVARCHAR(128),
    @nm_target_table  NVARCHAR(128),
    @ni_successful    INT = 0,
    @ni_failed        INT = 0,
    @tx_sql           NVARCHAR(MAX),
    @tx_nwl           NVARCHAR(1) = CHAR(10);

  DECLARE /* Get the last deployment date for the current model. */
    @meta_dt_valid_from DATETIME = (SELECT dt_deployment FROM deployment.last_deployment WHERE id_model = @id_model)

BEGIN
  
  /* Turn of Affected records feedback. */
  SET NOCOUNT ON;
    
  IF (1=1 /* Extract all "datasets". */) BEGIN

    DROP TABLE IF EXISTS ##to_deploy; SELECT TOP 10000
      dst.id_dataset, 
      dst.nm_target_schema, 
      dst.nm_target_table
    INTO ##to_deploy 
    FROM tsa_dta.tsa_dataset AS dst
    /* Join on the Process Group (this is based on already loaded in metadata, at this point the information in the TSA-table should be. */
    JOIN dta.process_group as pgp  ON dst.id_dataset = pgp.id_dataset and pgp.id_model = dst.id_model
    WHERE nm_target_schema != 'mdm'
    --
    -- Filter on Dataset that were cahnges sinds last deployment of the model.
    AND dst.id_dataset IN (
      SELECT id_dataset FROM dta.dataset       AS flt WHERE id_model = @id_model AND CASE WHEN @ip_is_override = 1 THEN 1 WHEN meta_dt_valid_from > @meta_dt_valid_from THEN 1 ELSE 0 END = 1 UNION
      SELECT id_dataset FROM dta.attribute     AS flt WHERE id_model = @id_model AND CASE WHEN @ip_is_override = 1 THEN 1 WHEN meta_dt_valid_from > @meta_dt_valid_from THEN 1 ELSE 0 END = 1 UNION
      SELECT id_dataset FROM dta.ingestion_etl AS flt WHERE id_model = @id_model AND CASE WHEN @ip_is_override = 1 THEN 1 WHEN meta_dt_valid_from > @meta_dt_valid_from THEN 1 ELSE 0 END = 1
    )
    --
    ORDER BY pgp.ni_process_group ASC
           , dst.nm_target_schema ASC
           , dst.nm_target_table  ASC;        

  END

  CREATE TABLE #deploy_failed (
    id_dataset       CHAR(32),
    nm_target_schema NVARCHAR(128),
    nm_target_table  NVARCHAR(128),
    tx_sql           NVARCHAR(MAX)
  );

  WHILE ((SELECT COUNT(*) FROM ##to_deploy) > 0) BEGIN
    
    /* Fetch Next "dataset" and remove from temp-table.. */
    SELECT @id_dataset       = id_dataset,
           @nm_target_schema = nm_target_schema,
           @nm_target_table  = nm_target_table 
    FROM (SELECT TOP 1 * FROM ##to_deploy) AS dst;
    DELETE FROM ##to_deploy WHERE id_dataset = @id_dataset;

	  BEGIN TRY /* Deploy Dataset. */
      EXEC deployment.dataset
        @ip_id_model         = @id_model,
        @ip_id_dataset       = @id_dataset,
        @ip_nm_target_schema = @nm_target_schema,
        @ip_nm_target_table  = @nm_target_table,
        @ip_is_debugging     = @ip_is_debugging,
        @ip_is_testing       = @ip_is_testing;
      
      /* Add 1 to the number of Successfull dataset deployed */
      SET @ni_successful = @ni_successful + 1;
      PRINT('----------------------------------------------------------------');
      PRINT('-- @id_model         : ' + @id_model);
      PRINT('-- @id_dataset       : ' + @id_dataset);
      PRINT('-- @nm_target_schema : ' + @nm_target_schema);
      PRINT('-- @nm_target_table  : ' + @nm_target_table);
      PRINT('-- #status           : Successfull');

    END TRY
    BEGIN CATCH
      
      /* Depolyment of Dataset failed, show the statement to excute the stored procedure that should have deployed the dataset. */
      SET @ni_failed = @ni_failed + 1; SET @tx_sql = '';
      SET @tx_sql=@tx_sql+@tx_sql+'----------------------------------------------------------------';
      SET @tx_sql=@tx_sql+@tx_nwl+'-- Deployment of "' + @nm_target_schema + '.' + @nm_target_table +'" failed!!';
      SET @tx_sql=@tx_sql+@tx_nwl+'-- Run stored procdure in debug mode for more details.';
      SET @tx_sql=@tx_sql+@tx_nwl+'DECLARE	@return_value int';
      SET @tx_sql=@tx_sql+@tx_nwl+'';
      SET @tx_sql=@tx_sql+@tx_nwl+'EXEC	@return_value = deployment.dataset';
      SET @tx_sql=@tx_sql+@tx_nwl+'		@ip_id_model         = N''' + @id_model         + ''',';
      SET @tx_sql=@tx_sql+@tx_nwl+'		@ip_id_dataset       = N''' + @id_dataset       + ''',';
      SET @tx_sql=@tx_sql+@tx_nwl+'		@ip_nm_target_schema = N''' + @nm_target_schema + ''',';
      SET @tx_sql=@tx_sql+@tx_nwl+'		@ip_nm_target_table  = N''' + @nm_target_table  + ''',';
      SET @tx_sql=@tx_sql+@tx_nwl+'		@ip_is_debugging     = 1,';
      SET @tx_sql=@tx_sql+@tx_nwl+'		@ip_is_testing       = 0';
      SET @tx_sql=@tx_sql+@tx_nwl+'';
      SET @tx_sql=@tx_sql+@tx_nwl+'SELECT ''Return Value'' = @return_value';
      INSERT INTO #deploy_failed (id_dataset, nm_target_schema, nm_target_table, tx_sql) VALUES (@id_dataset, @nm_target_schema, @nm_target_table, @tx_sql);

    END CATCH
    
  END
  
  WHILE ((SELECT COUNT(*) FROM #deploy_failed) > 0) BEGIN
    
    /* Fetch Next "dataset" and remove from temp-table.. */
    SELECT @id_dataset       = id_dataset,
           @nm_target_schema = nm_target_schema,
           @nm_target_table  = nm_target_table,
           @tx_sql           = tx_sql
    FROM (SELECT TOP 1 * FROM #deploy_failed) AS dst;
    DELETE FROM #deploy_failed WHERE id_dataset = @id_dataset;

    PRINT('');
    PRINT('----------------------------------------------------------------');
    PRINT('-- @id_model         : ' + @id_model);
    PRINT('-- @id_dataset       : ' + @id_dataset);
    PRINT('-- @nm_target_schema : ' + @nm_target_schema);
    PRINT('-- @nm_target_table  : ' + @nm_target_table);
    PRINT('-- #status           : Failed');
    PRINT('----------------------------------------------------------------');
    PRINT('-- SQL for Debugging/Testing of Failed "Dataset"');
    PRINT(@tx_sql);
    PRINT('----------------------------------------------------------------');
    
  END

  PRINT('');
  PRINT('================================================================');
  PRINT('-- Deployment Summary for Model : ' + @id_model);
  PRINT('-- # Successful Datasets Deployed : ' + CAST(@ni_successful AS NVARCHAR(10)));
  PRINT('-- # Failed Datasets Deployed     : ' + CAST(@ni_failed   AS NVARCHAR(10)));
  PRINT('-- # Total Datasets Deployed      : ' + CAST((@ni_successful + @ni_failed) AS NVARCHAR(10)));
  PRINT('================================================================');
  PRINT('');

END
GO