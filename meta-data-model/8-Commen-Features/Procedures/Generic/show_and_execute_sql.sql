CREATE PROCEDURE gnc_commen.show_and_execute_sql

  /* Input Parameters */
  @ip_tx_message NVARCHAR(999) = '',
  @ip_tx_sql     NVARCHAR(MAX) = '',

  /* Input Paramters for "Debugging". */
  @ip_is_debugging     BIT = 0,
  @ip_is_testing       BIT = 0

AS BEGIN
  
  /* ----------------------------------------------------------------------- */
  /* This procedure will handle the writtin of a message and/or SQL-code to  */
  /* the output-consol. Based on the input parameter @ip_is_debugging and    */
  /* the execution of the SQL code is controlled by @ip_is_testing.          */ 
  /* ----------------------------------------------------------------------- */
  
  IF (@ip_is_debugging = 1 AND @ip_tx_message != '') BEGIN EXEC gnc_commen.to_concol_window @ip_tx_message; END;
  IF (@ip_is_debugging = 1 AND @ip_tx_sql     != '') BEGIN EXEC gnc_commen.to_concol_window @ip_tx_sql; END;
  IF (@ip_is_testing   = 0) BEGIN EXEC sp_executesql @ip_tx_sql; END;

END
GO