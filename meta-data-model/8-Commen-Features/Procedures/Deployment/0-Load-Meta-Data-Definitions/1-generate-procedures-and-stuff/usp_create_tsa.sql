CREATE PROCEDURE deployment.usp_create_tsa
  
  /* Input Parameters */
  @ip_nm_schema NVARCHAR(128) = 'srd',
  @ip_nm_table  NVARCHAR(128) = 'dq_risk_level',

  /* Debuging Parameter(s) */
  @ip_is_debugging BIT = 0

AS DECLARE /* Local Variables */

  @tx_sql NVARCHAR(MAX),
  @tx_msg NVARCHAR(999);

BEGIN
  
  SET @tx_msg = '/* Drop table "' + @ip_nm_schema + '.tsa_' + @ip_nm_table + '" is exists */';
  SET @tx_sql = 'DROP TABLE IF EXISTS tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table; 
  EXEC gnc_commen.show_and_execute_sql @tx_msg, @tx_sql, @ip_is_debugging;

  SET @tx_msg = '/* Copy Table "' + @ip_nm_schema + '.tsa_' + @ip_nm_table + '" to "Temporal Staging Area". */';
  SET @tx_sql = 'SELECT * INTO        tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' '
           + 'FROM [' + @ip_nm_schema + '].[' + @ip_nm_table + '] ' 
           + 'WHERE ' + CASE WHEN @ip_nm_table LIKE 'transformation_%'      THEN 'meta_is_active = 1'
                             WHEN @ip_nm_table    = 'dq_involved_attribute' THEN 'meta_is_active = 1'
                             ELSE '1 = 2'
                        END; 
  EXEC gnc_commen.show_and_execute_sql @tx_msg, @tx_sql, @ip_is_debugging;
  
  SET @tx_sql = 'ALTER TABLE          tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' DROP COLUMN meta_dt_valid_from'; EXEC gnc_commen.show_and_execute_sql '', @tx_sql, @ip_is_debugging;
  SET @tx_sql = 'ALTER TABLE          tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' DROP COLUMN meta_dt_valid_till'; EXEC gnc_commen.show_and_execute_sql '', @tx_sql, @ip_is_debugging;
  SET @tx_sql = 'ALTER TABLE          tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' DROP COLUMN meta_is_active';     EXEC gnc_commen.show_and_execute_sql '', @tx_sql, @ip_is_debugging;
  SET @tx_sql = 'ALTER TABLE          tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' DROP COLUMN meta_ch_rh';         EXEC gnc_commen.show_and_execute_sql '', @tx_sql, @ip_is_debugging;
  SET @tx_sql = 'ALTER TABLE          tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' DROP COLUMN meta_ch_bk';         EXEC gnc_commen.show_and_execute_sql '', @tx_sql, @ip_is_debugging;
  SET @tx_sql = 'ALTER TABLE          tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' DROP COLUMN meta_ch_pk';         EXEC gnc_commen.show_and_execute_sql '', @tx_sql, @ip_is_debugging;
  SET @tx_sql = 'ALTER TABLE          tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' DROP COLUMN meta_dt_created';    EXEC gnc_commen.show_and_execute_sql '', @tx_sql, @ip_is_debugging;
END
GO