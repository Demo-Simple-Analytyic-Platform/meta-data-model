CREATE PROCEDURE deployment.usp_create_tmp AS BEGIN

  DECLARE /* Local Variables */
    @nm_schema NVARCHAR(128),
    @nm_table  NVARCHAR(128),
    @tx_sql    NVARCHAR(MAX);

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
      EXEC sp_executesql @tx_sql;
      DELETE FROM #schemas WHERE nm_schema = @nm_schema;
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

      PRINT('@nm_schema : "'+ @nm_schema + '.'+ @nm_table +'"');
      /* Create temp-table */
      EXEC deployment.usp_create_tsa @nm_schema, @nm_table;
      EXEC deployment.usp_create_get @nm_schema, @nm_table;
      EXEC deployment.usp_create_usp @nm_schema, @nm_table;
    
      /* Drop Record from temp-table. */
      DELETE FROM ##def WHERE nm_schema = @nm_schema AND nm_table = @nm_table;

    END /* WHILE */

  END TRY
  BEGIN CATCH
    DECLARE

      @tx_message NVARCHAR(MAX) = '';

    BEGIN

	    /* Build Text Message for Error info. */
	    SET @tx_message += '=== Error Message ================================================'     + CHAR(10)
	    SET @tx_message += 'Procedure : ' + CONVERT(NVARCHAR(255), ISNULL(ERROR_PROCEDURE(),'n/a'))	+ CHAR(10)
	    SET @tx_message += 'Line      : ' + CONVERT(NVARCHAR(255), ERROR_LINE())				            + CHAR(10)
	    SET @tx_message += 'Numer     : ' + CONVERT(NVARCHAR(255), ERROR_NUMBER())			            + CHAR(10)
	    SET @tx_message += 'Message   : ' + CONVERT(NVARCHAR(255), ERROR_MESSAGE())			            + CHAR(10)
	    SET @tx_message += 'Severity  : ' + CONVERT(NVARCHAR(255), ERROR_SEVERITY())		            + CHAR(10)
	    SET @tx_message += 'State     : ' + CONVERT(NVARCHAR(255), ERROR_STATE())				            + CHAR(10)
	    SET @tx_message += '=================================================================='     + CHAR(10)
      RAISERROR(@tx_message, 16, 1);

    END
  END CATCH
END
GO
