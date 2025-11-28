CREATE PROCEDURE deployment.usp_execute_all_usp 

  /* Input Paramter(s) */
  @ip_is_debugging BIT = 0

AS BEGIN
  
  /* Turn of Affected records feedback. */
  SET NOCOUNT ON;

  DECLARE /* Local Variables */
    @tx_sql NVARCHAR(MAX);

  BEGIN

    /* Extract a list of "procedure"  to be executed. */ 
    DROP TABLE IF EXISTS ##sql; SELECT 
      tx_sql = 'BEGIN EXECUTE tsa_' + TABLE_SCHEMA + '.usp_' + TABLE_NAME + ' @ip_is_debugging = ' + CONVERT(NVARCHAR(1), @ip_is_debugging) + '; END' 
    INTO ##sql FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA IN ('srd' , 'ohg', 'dta', 'dqm')
    AND   CASE 
            WHEN TABLE_SCHEMA = 'dta' 
             AND TABLE_NAME IN (
              'transformation_part',
              'transformation_dataset', 
              'transformation_column_mapping', 
              'transformation_part_attribute',
              'transformation_dataset_attribute', 
              'transformation_column_mapping_attribute') 
            THEN 1

            WHEN TABLE_SCHEMA = 'dqm' 
            AND  TABLE_NAME IN (
              'dq_requirement', 
              'dq_control',
              'dq_threshold')
            THEN 1

            WHEN TABLE_SCHEMA = 'dta' 
            AND  TABLE_NAME IN (
              'model', 
              'database', 
              'dataset', 
              'attribute', 
              'ingestion_etl', 
              'parameter_value', 
              'schedule')
            THEN 1

            WHEN TABLE_SCHEMA = 'srd'
            AND  TABLE_NAME IN (
              'development_status', 
              'datatype', 
              'parameter', 
              'parameter_group', 
              'dq_dimension', 
              'dq_risk_level', 
              'dq_result_status', 
              'dq_review_status', 
              'processing_status', 
              'processing_step')
            THEN 1

            WHEN TABLE_SCHEMA = 'ohg'
            AND  TABLE_NAME IN (
              'group', 
              'hierarchy', 
              'related')
            THEN 1
            
            ELSE 0

          END = 1;
    
    /* Loop throught the "SQL"-statements, Show and EXECUTE them. */
    WHILE ((SELECT COUNT(*) FROM ##sql) > 0) BEGIN 
      SELECT @tx_sql = tx_sql FROM (SELECT TOP 1 * FROM ##sql) AS rec; 
      DELETE FROM ##sql WHERE tx_sql = @tx_sql; 
      EXEC gnc.show_and_execute_sql '', @tx_sql, @ip_is_debugging;
    END /* WHILE */ DROP TABLE IF EXISTS ##sql; 

  END

END
GO
