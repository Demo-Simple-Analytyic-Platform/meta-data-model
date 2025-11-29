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
    DROP TABLE IF EXISTS ##sql; 
    SELECT tx_sql = 'BEGIN EXECUTE tsa_' + nm_schema + '.usp_' + nm_table + ' @ip_is_debugging = ' + CONVERT(NVARCHAR(1), @ip_is_debugging) + '; END' 
    INTO ##sql 
    FROM deployment.mdm_objects;
    
    /* Loop throught the "SQL"-statements, Show and EXECUTE them. */
    WHILE ((SELECT COUNT(*) FROM ##sql) > 0) BEGIN 
      SELECT @tx_sql = tx_sql FROM (SELECT TOP 1 * FROM ##sql) AS rec; 
      DELETE FROM ##sql WHERE tx_sql = @tx_sql; 
      EXEC gnc.show_and_execute_sql '', @tx_sql, @ip_is_debugging;
    END /* WHILE */ DROP TABLE IF EXISTS ##sql; 

  END

END
GO
