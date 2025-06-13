CREATE PROCEDURE mdm.create_column_store_index

  /* Input Parameters */
  @ip_nm_target_schema NVARCHAR(128),
  @ip_nm_target_table  NVARCHAR(128),

  /* Input Paramters for "Debugging". */
  @ip_is_debugging     BIT = 0,
  @ip_is_testing       BIT = 0

AS DECLARE /* Local Variables */

  -- Helpers for SQL code Generation
  @tx_sql     NVARCHAR(MAX) = N'',
  @tx_message NVARCHAR(MAX) = N'',

  -- Check if Columnstore index already exists
  @is_table_already_columnstore BIT,

  -- Helper "columnstore"-index tsa
  @nm_index NVARCHAR(128) = 'idx_ccs_' + @ip_nm_target_schema + '_' +  @ip_nm_target_table  

BEGIN

  /* Check if table is already converted into columnstore */
  SET @tx_sql = CASE WHEN ISNULL((SELECT 1 FROM sys.indexes WHERE [name] = @nm_index AND [object_id] = OBJECT_ID(@ip_nm_target_schema + '.' + @ip_nm_target_table)),0) = 1
                     THEN '-- The table "' + @ip_nm_target_schema + '"."' +  @ip_nm_target_table + '" was already converted to a columnstore.'
                     ELSE 'CREATE CLUSTERED COLUMNSTORE INDEX ' + @nm_index + ' ON [' + @ip_nm_target_schema + '].[' +  @ip_nm_target_table + ']'
                END;
  SET @tx_message = '-- SQL code for "Converting" table from "rowstore" to "columnstore".';
  
  /* Show and Execute SQL Statements */
  EXEC gnc_commen.show_and_execute_sql @tx_message, @tx_sql, @ip_is_debugging, @ip_is_testing;

END
RETURN 0
GO