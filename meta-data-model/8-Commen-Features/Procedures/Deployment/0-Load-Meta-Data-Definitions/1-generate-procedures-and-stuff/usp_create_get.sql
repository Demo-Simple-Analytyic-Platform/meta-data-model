CREATE PROCEDURE deployment.usp_create_get

  /* Input Parameters */
  @ip_nm_schema NVARCHAR(128),
  @ip_nm_table  NVARCHAR(128)

AS BEGIN
  
  DECLARE /* Local Variables */
    @tx_now    NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX), GETDATE(), 120),
    @tx_sql    NVARCHAR(MAX) = '',
    @tx_emp    NVARCHAR(1)   = '',
    @tx_nwl    NVARCHAR(1)   = CHAR(10),
    @nm_column NVARCHAR(128) = '';
  
  BEGIN

    DROP TABLE IF EXISTS ##columns; 
    SELECT nm_column = COLUMN_NAME
    INTO ##columns
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @ip_nm_schema
    AND   TABLE_NAME   = @ip_nm_table
    AND   COLUMN_NAME NOT LIKE 'meta_%'
    ORDER BY ORDINAL_POSITION ASC;

    SET @tx_sql = 'DROP VIEW IF EXISTS tsa_' + @ip_nm_schema + '.get_' + @ip_nm_table;
    EXEC sp_executesql @tx_sql;

    SET @tx_sql  = @tx_emp + 'CREATE VIEW tsa_' + @ip_nm_schema + '.get_' + @ip_nm_table + ' AS SELECT *, ';
    SET @tx_sql += @tx_nwl + '  meta_dt_valid_from = CONVERT(DATETIME, "' + @tx_now     + '"),';        
    SET @tx_sql += @tx_nwl + '  meta_dt_valid_till = CONVERT(DATETIME, "9999-12-31 23:59:59"),';        
    SET @tx_sql += @tx_nwl + '  meta_is_active     = CONVERT(BIT,      1),';
    SET @tx_sql += @tx_nwl + '  meta_ch_rh         = CONVERT(CHAR(32), HASHBYTES("MD5", CONCAT(CONVERT(NVARCHAR(MAX),""),';

    /* Add all "Columns" for the "rowhas"h". */
    WHILE ((SELECT count(*) FROM ##columns) > 0) BEGIN
        SELECT @nm_column = nm_column FROM (SELECT TOP 1 nm_column FROM ##columns) AS nxt
        SET @tx_sql += @tx_nwl + '                       "|", ' + @nm_column + ',';
        DELETE FROM ##columns WHERE nm_column = @nm_column;
    END /* Loop */

    SET @tx_sql += @tx_nwl + '                       "|")), 2),';
    SET @tx_sql += @tx_nwl + '  meta_ch_bk         = CONVERT(CHAR(32), HASHBYTES("MD5", CONCAT(CONVERT(NVARCHAR(MAX),""),';
    SET @tx_sql += @tx_nwl + '                       "|", id_' + @ip_nm_table + ',';
    SET @tx_sql += @tx_nwl + '                       "|")), 2),';
    SET @tx_sql += @tx_nwl + '  meta_ch_pk         = CONVERT(CHAR(32), HASHBYTES("MD5", CONCAT(CONVERT(NVARCHAR(MAX),""),';
    SET @tx_sql += @tx_nwl + '                       "|", id_' + @ip_nm_table + ',';
    SET @tx_sql += @tx_nwl + '                       "|", CONVERT(DATETIME, "' + @tx_now + '"),';
    SET @tx_sql += @tx_nwl + '                       "|")), 2)';
    SET @tx_sql += @tx_nwl + 'FROM tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table;
    SET @tx_sql += @tx_nwl + 'WHERE id_model IN (SELECT id_model FROM mdm.current_model)';

    /* Execute SQL Statement */
    SET @tx_sql = REPLACE(@tx_sql,'"', '''');
    PRINT(@tx_sql); EXEC sp_executesql @tx_sql;
    
    /* All done. */
    DROP TABLE IF EXISTS ##columns; 

  END

END
GO
