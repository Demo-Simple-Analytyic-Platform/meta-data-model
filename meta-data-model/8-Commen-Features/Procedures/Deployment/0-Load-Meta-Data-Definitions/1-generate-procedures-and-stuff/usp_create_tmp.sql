CREATE PROCEDURE deployment.usp_create_tmp

  /* Input PAramter(s) */
  @ip_is_debugging BIT = 0
  
AS BEGIN

  DECLARE /* Local Variables */
    @nm_schema NVARCHAR(128),
    @nm_table  NVARCHAR(128),
    @tx_sql    NVARCHAR(MAX),
    @tx_msg    NVARCHAR(999);

  BEGIN TRY

    /* Create tsa-schemas */
    DROP TABLE IF EXISTS #schemas; SELECT 
      tmp.nm_schema, 'CREATE SCHEMA ' + tmp.nm_schema AS tx_sql
    INTO #schemas
    FROM (SELECT 'tsa_' + val.SCHEMA_NAME AS nm_schema FROM ( VALUES ('srd'), ('ohg'), ('dta'), ('dqm')) AS val (SCHEMA_NAME)) AS tmp
    LEFT JOIN INFORMATION_SCHEMA.SCHEMATA AS shm ON shm.SCHEMA_NAME = tmp.nm_schema
    WHERE shm.SCHEMA_NAME IS NULl;

    WHILE ((SELECT COUNT(*) FROM #schemas) > 0) BEGIN
      SELECT @nm_schema = nm_schema, @tx_sql = tx_sql FROM (SELECT TOP 1 * FROM #schemas) AS rec;
      DELETE FROM #schemas WHERE nm_schema = @nm_schema;
      SET @tx_msg = 'Create Temp Table : "' + @nm_schema + '"';
      EXEC gnc_commen.show_and_execute_sql @tx_msg, @tx_sql, @ip_is_debugging;
    END /* WHILE */
  
    DROP TABLE IF EXISTS ##def; SELECT nm_schema = TABLE_SCHEMA, nm_table  = TABLE_NAME INTO ##def FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA IN ('srd' , 'ohg', 'dta', 'dqm') AND TABLE_NAME NOT LIKE 'get_%' AND TABLE_NAME NOT LIKE 'tsa_%' AND TABLE_TYPE = 'BASE TABLE'
    AND   TABLE_NAME   IN (
      'transformation_attribute', 'transformation_dataset', 'transformation_mapping', 'transformation_part',
      'dq_involved_attribute', 'dq_control', 'dq_requirement', 'dq_threshold', 
      'model', 'database', 'attribute', 'dataset', 'ingestion_etl', 'parameter_value', 'schedule',
      'datatype', 'development_status', 'dq_dimension', 'dq_result_status', 'dq_review_status', 'dq_risk_level', 'parameter', 'parameter_group', 'processing_status', 'processing_step',
      'group', 'hierarchy', 'related');
    
    WHILE ((SELECT COUNT(*) FROM ##def) > 0) BEGIN

      /* Fetch next nm_schema and nm_table */
      SELECT @nm_schema = nm_schema, @nm_table  = nm_table FROM (SELECT TOP 1 * FROM ##def) AS rec;
      EXEC gnc_commen.show_and_execute_sql @tx_msg, '', @ip_is_debugging;

      /* Create temp-table */
      EXEC deployment.usp_create_tsa @nm_schema, @nm_table, @ip_is_debugging;
      EXEC deployment.usp_create_get @nm_schema, @nm_table, @ip_is_debugging;
      EXEC deployment.usp_create_usp @nm_schema, @nm_table, @ip_is_debugging;
    
      /* Drop Record from temp-table. */
      DELETE FROM ##def WHERE nm_schema = @nm_schema AND nm_table = @nm_table;

    END /* WHILE */

  END TRY
  BEGIN CATCH

	  /* Build Text Message for Error info. */
	  SET @tx_msg  = '=== Error Message ================================================'     + CHAR(10)
	  SET @tx_msg += 'Procedure : ' + CONVERT(NVARCHAR(255), ISNULL(ERROR_PROCEDURE(),'n/a'))	+ CHAR(10)
	  SET @tx_msg += 'Line      : ' + CONVERT(NVARCHAR(255), ERROR_LINE())				            + CHAR(10)
	  SET @tx_msg += 'Numer     : ' + CONVERT(NVARCHAR(255), ERROR_NUMBER())			            + CHAR(10)
	  SET @tx_msg += 'Message   : ' + CONVERT(NVARCHAR(255), ERROR_MESSAGE())			            + CHAR(10)
	  SET @tx_msg += 'Severity  : ' + CONVERT(NVARCHAR(255), ERROR_SEVERITY())		            + CHAR(10)
	  SET @tx_msg += 'State     : ' + CONVERT(NVARCHAR(255), ERROR_STATE())				            + CHAR(10)
	  SET @tx_msg += '=================================================================='     + CHAR(10)
    RAISERROR(@tx_msg, 16, 1);

  END CATCH
END
GO
