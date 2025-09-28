CREATE PROCEDURE [deployment].[deploy_datasets]

    /* Input Parameters */
    @ip_is_debugging     BIT = 0,
    @ip_is_testing       BIT = 0

AS DECLARE 
      
    /* Data Attributes */
    @id_model         CHAR(32) = (SELECT id_model FROM mdm.current_model),
    @id_dataset       CHAR(32),
    @nm_target_schema NVARCHAR(128),
    @nm_target_table  NVARCHAR(128);

  DECLARE /* Get the last deployment date for the current model. */
    @meta_dt_valid_from DATETIME = (SELECT dt_deployment FROM mdm.last_deployment WHERE id_model = @id_model)

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
    AND dst.id_dataset IN (SELECT id_dataset FROM dta.dataset AS flt 
                           WHERE  id_model           = @id_model 
                           AND    meta_dt_valid_from > @meta_dt_valid_from )
    --
    ORDER BY pgp.ni_process_group ASC
           , dst.nm_target_schema ASC
           , dst.nm_target_table  ASC;        

  END

  WHILE ((SELECT COUNT(*) FROM ##to_deploy) > 0) BEGIN
    
    /* Fetch Next "dataset" and remove from temp-table.. */
    SELECT @id_dataset       = id_dataset,
           @nm_target_schema = nm_target_schema,
           @nm_target_table  = nm_target_table 
    FROM (SELECT TOP 1 * FROM ##to_deploy) AS dst;
    DELETE FROM ##to_deploy WHERE id_dataset = @id_dataset;

	  BEGIN TRY /* Deploy Dataset. */
      EXEC mdm.deploy_dataset
        @ip_id_model         = @id_model,
        @ip_id_dataset       = @id_dataset,
        @ip_nm_target_schema = @nm_target_schema,
        @ip_nm_target_table  = @nm_target_table,
        @ip_is_debugging     = @ip_is_debugging,
        @ip_is_testing       = @ip_is_testing;
      
      /* Show what is being deployed. */
      PRINT('----------------------------------------------------------------');
      PRINT('@id_model         : ' + @id_model);
      PRINT('@id_dataset       : ' + @id_dataset);
      PRINT('@nm_target_schema : ' + @nm_target_schema);
      PRINT('@nm_target_table  : ' + @nm_target_table);
      PRINT('#status           : Successfull');

    END TRY
    BEGIN CATCH
      /* Depolyment of Dataset failed, show the statement to excute the stored procedure that should have deployed the dataset. */
      PRINT('----------------------------------------------------------------');
      PRINT('-- Deployment of "' + @nm_target_schema + '.' + @nm_target_table +'" failed!!');
      PRINT('-- Run stored procdure in debug mode for more details.');
      PRINT('DECLARE	@return_value int');
      PRINT(''); 
      PRINT('EXEC	@return_value = [mdm].[deploy_dataset]'); 
      PRINT('		@ip_id_model         = N''' + @id_model         + ''','); 
      PRINT('		@ip_id_dataset       = N''' + @id_dataset       + ''','); 
      PRINT('		@ip_nm_target_schema = N''' + @nm_target_schema + ''','); 
      PRINT('		@ip_nm_target_table  = N''' + @nm_target_table  + ''','); 
      PRINT('		@ip_is_debugging     = 1,'); 
      PRINT('		@ip_is_testing       = 0'); 
      PRINT(''); 
      PRINT('SELECT ''Return Value'' = @return_value'); 
      PRINT('');
    END CATCH
    PRINT('');

  END
  
END
GO