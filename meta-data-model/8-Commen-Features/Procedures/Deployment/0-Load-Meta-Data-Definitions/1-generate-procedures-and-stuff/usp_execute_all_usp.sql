CREATE PROCEDURE deployment.usp_execute_all_usp 

  /* Input Parameters */
  @ip_is_only_metadata BIT = 1

AS BEGIN
  
  /* Turn of Affected records feedback. */
  SET NOCOUNT ON;

  DECLARE /* Local Variables */
    @tx_sql NVARCHAR(MAX);

  BEGIN

    /* Extract a list of "procedure"  to be executed. */ 
    DROP TABLE IF EXISTS ##sql; SELECT 
      tx_sql = 'BEGIN EXECUTE tsa_' + TABLE_SCHEMA + '.usp_' + TABLE_NAME + '; END' 
    INTO ##sql FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA IN ('srd' , 'ohg', 'dta', 'dqm')
    AND   CASE 
            WHEN @ip_is_only_metadata = 0 AND TABLE_SCHEMA = 'dta' AND TABLE_NAME IN ('transformation_attribute', 'transformation_dataset', 'transformation_mapping', 'transformation_part') 
            THEN 1

            WHEN @ip_is_only_metadata = 0 AND TABLE_SCHEMA = 'dqm' AND TABLE_NAME IN ('dq_involved_attribute')
            THEN 1

            WHEN @ip_is_only_metadata = 1 AND TABLE_SCHEMA = 'dqm' AND TABLE_NAME IN ('dq_control', 'dq_requirement', 'dq_threshold')
            THEN 1

            WHEN @ip_is_only_metadata = 1 AND TABLE_SCHEMA = 'dta' AND TABLE_NAME IN ('model', 'database', 'attribute', 'dataset', 'ingestion_etl', 'parameter_value', 'schedule')
            THEN 1

            WHEN @ip_is_only_metadata = 1 AND TABLE_SCHEMA = 'srd'
            THEN 1

            WHEN @ip_is_only_metadata = 1 AND TABLE_SCHEMA = 'ohg'
            THEN 1
            
            ELSE 0

          END = 1
    
    ;
    
    /* Loop throught the "SQL"-statements, Show and EXECUTE them. */
    WHILE ((SELECT COUNT(*) FROM ##sql) > 0) BEGIN SELECT @tx_sql = tx_sql FROM (SELECT TOP 1 * FROM ##sql) AS rec; PRINT(@tx_sql); EXEC sp_executesql @tx_sql; DELETE FROM ##sql WHERE tx_sql = @tx_sql; END /* WHILE */ DROP TABLE IF EXISTS ##sql; 

  END

END
GO