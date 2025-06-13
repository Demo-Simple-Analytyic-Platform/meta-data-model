CREATE PROCEDURE deployment.usp_create_usp
  
  /* Input Parameter(s) */
  @ip_nm_schema NVARCHAR(128),
  @ip_nm_table  NVARCHAR(128)

AS BEGIN
  
  DECLARE /* Local Variables */
    @tx_prc    NVARCHAR(MAX) = '[tsa_' + @ip_nm_schema + '].[usp_' + @ip_nm_table + ']',
    @tx_src    NVARCHAR(MAX) = '[tsa_' + @ip_nm_schema + '].[get_' + @ip_nm_table + ']',
    @tx_tgt    NVARCHAR(MAX) = '[' +     @ip_nm_schema + '].['     + @ip_nm_table + ']',
    @tx_col    NVARCHAR(MAX) = '',
    @tx_sql    NVARCHAR(MAX) = '',
    @tx_emp    NVARCHAR(1)   = '',
    @tx_nwl    NVARCHAR(1)   = CHAR(10),
    @nm_column NVARCHAR(128) = '';
      
  BEGIN

    /* Build, Show and Execute  SQL-Statement for Drop "Procedure" if already exists. */
    SET @tx_sql = 'DROP PROCEDURE IF EXISTS ' + @tx_prc + ''; 
    PRINT(@tx_sql); 
    EXEC sp_executesql @tx_sql;
    
    /* Extract "temp"-table with Columns of "Target"-table, exclude the "meta-attributes. */
    DROP TABLE IF EXISTS ##columns; SELECT nm_column = COLUMN_NAME INTO ##columns FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = @ip_nm_schema AND TABLE_NAME = @ip_nm_table AND COLUMN_NAME NOT LIKE 'meta_%' ORDER BY ORDINAL_POSITION ASC;

    /* String all the "Colums" in the "temp"-table together with "s."-alias, after drop the "temp"-table. */
    WHILE ((SELECT COUNT(*) FROM ##columns) > 0) BEGIN 
      SELECT @nm_column = nm_column FROM (SELECT TOP 1 * FROM ##columns) AS rec; 
      SET @tx_col += 's.' + @nm_column + ', '; 
      DELETE FROM ##columns WHERE nm_column = @nm_column; 
    END /* WHILE */ DROP TABLE IF EXISTS ##columns; 

    /* Build, Show and Execute SQL-statement for "creating" the "Procedure". */
    SET @tx_sql  = @tx_emp + 'CREATE PROCEDURE ' + @tx_prc + ' AS BEGIN';
    SET @tx_sql += @tx_nwl + '  ';
    SET @tx_sql += @tx_nwl + '  UPDATE t SET t.meta_is_active = 0, t.meta_dt_valid_till = ISNULL((SELECT MAX(meta_dt_valid_from) FROM ' + @tx_src + '), GETDATE())';
    SET @tx_sql += @tx_nwl + '  FROM ' + @tx_tgt + ' AS t LEFT JOIN ' + @tx_src + ' AS s ON t.meta_ch_rh = s.meta_ch_rh';
    SET @tx_sql += @tx_nwl + '  WHERE t.meta_is_active = 1 AND t.id_model IN (SELECT id_model FROM mdm.current_model) AND s.meta_ch_pk IS NULL ;';
    SET @tx_sql += @tx_nwl + '  ';
    SET @tx_sql += @tx_nwl + '  INSERT INTO ' + @tx_tgt + ' (' + REPLACE(@tx_col, 's.', '') + ' meta_dt_valid_from, meta_dt_valid_till, meta_is_active, meta_ch_rh, meta_ch_bk, meta_ch_pk)';
    SET @tx_sql += @tx_nwl + '  SELECT ' + @tx_col + ' s.meta_dt_valid_from, s.meta_dt_valid_till, s.meta_is_active, s.meta_ch_rh, s.meta_ch_bk, s.meta_ch_pk';
    SET @tx_sql += @tx_nwl + '  FROM ' + @tx_src + ' AS s LEFT JOIN ' + @tx_tgt + ' AS t ON t.meta_is_active = 1 AND t.meta_ch_rh = s.meta_ch_rh AND t.id_model IN (SELECT id_model FROM mdm.current_model)';
    SET @tx_sql += @tx_nwl + '  WHERE t.meta_ch_pk IS NULL;';
    SET @tx_sql += @tx_nwl + '  ';
    SET @tx_sql += @tx_nwl + 'END';
    PRINT(@tx_sql); 
    EXEC sp_executesql @tx_sql;

  END

END
GO
