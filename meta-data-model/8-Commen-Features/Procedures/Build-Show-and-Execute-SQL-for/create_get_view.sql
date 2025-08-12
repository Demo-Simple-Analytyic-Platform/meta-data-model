CREATE PROCEDURE mdm.create_get_view

  /* Input Parameters */
  @ip_nm_target_schema NVARCHAR(128),
  @ip_nm_target_table  NVARCHAR(128),

  /* Input Paramters for "Debugging". */
  @ip_is_debugging     BIT = 0,
  @ip_is_testing       BIT = 0

AS DECLARE /* Local Variables */
  
  @id_dataset    CHAR(32) = (SELECT id_dataset FROM dta.dataset WHERE meta_is_active = 1 AND nm_target_schema = @ip_nm_target_schema AND nm_target_table = @ip_nm_target_table),
  @tx_message    NVARCHAR(999),
  @tx_sql        NVARCHAR(MAX),

  @emp NVARCHAR(1)   = '',
  @nwl NVARCHAR(1)   = CHAR(10),
  @sql NVARCHAR(MAX) = '',
  @frm NVARCHAR(MAX),
  @tll NVARCHAR(MAX),
  @col NVARCHAR(128),
  @rwh NVARCHAR(MAX) = '',
  @bks NVARCHAR(MAX) = '',
  @pks NVARCHAR(MAX) = '',
  @ord INT,
  @idx INT = 0,
  @max INT = 100

BEGIN

  IF (1=1 /* Extract "Columns"-dataset, exclude the "meta-attributes. */) BEGIN
    
    DROP TABLE IF EXISTS #columns; SELECT 
      o = att.ni_ordering,
      c = att.nm_target_column 
    INTO #columns FROM dta.attribute AS att
    WHERE att.id_dataset     = @id_dataset
    AND   att.meta_is_active = 1
    ORDER BY ni_ordering ASC;
    
    DROP TABLE IF EXISTS #busineskeys; SELECT 
      o = att.ni_ordering,
      c = att.nm_target_column 
    INTO #busineskeys FROM dta.attribute AS att JOIN dta.dataset AS dst ON dst.meta_is_active = 1 AND dst.id_dataset = @id_dataset
    WHERE att.id_dataset     = @id_dataset
    AND   att.meta_is_active = 1
    AND   att.is_businesskey = 1
    ORDER BY ni_ordering ASC;

  END

  IF (1=1 /* Fetch SQL for "meta_dt_valid_from" and "meta_dt_valid_till" */) BEGIN
    SELECT @frm = tx_sql_for_meta_dt_valid_from,
           @tll = tx_sql_for_meta_dt_valid_till
    FROM dta.ingestion_etl
    WHERE meta_is_active = 1
    AND   id_dataset = @id_dataset;
  END
  
  IF (1=1 /* String all the "Colums" in the "temp"-table together with "s."-alias, after drop the "temp"-table. */) BEGIN
	  
    SET @rwh += 'CONCAT(CONVERT(NVARCHAR(MAX), ""),'+ @nwl + '  CONCAT(';
    WHILE ((SELECT COUNT(*) FROM #columns) > 0) BEGIN 
      SELECT @col=c, @ord=o FROM (SELECT TOP 1 * FROM #columns ORDER BY o ASC) AS rec; 
      DELETE FROM #columns WHERE o = @ord; 
	    IF (@idx = @max) BEGIN SET @idx += 1; SET @rwh += '"|")'; END;
	    IF (@idx > @max) BEGIN SET @idx  = 0; SET @rwh += ',' + @nwl + '  CONCAT(';END;
	    IF (@idx < @max) BEGIN SET @idx += 1; SET @rwh += ' "|", src.['+@col+'],'; END;
    END /* WHILE */ DROP TABLE IF EXISTS #columns; 
	  SET @rwh += '"|")' + @nwl + '))';

	  SET @bks += 'CONCAT(CONVERT(NVARCHAR(MAX), ""),'+ @nwl + '  CONCAT(';
    WHILE ((SELECT COUNT(*) FROM #busineskeys) > 0) BEGIN 
      SELECT @col=c, @ord=o FROM (SELECT TOP 1 * FROM #busineskeys ORDER BY o ASC) AS rec; 
      DELETE FROM #busineskeys WHERE o = @ord; 
	    IF (@idx = @max) BEGIN SET @idx += 1; SET @bks += '"|")'; END;
	    IF (@idx > @max) BEGIN SET @idx  = 0; SET @bks += ',' + @nwl + '  CONCAT(';END;
	    IF (@idx < @max) BEGIN SET @idx += 1; SET @bks += ' "|", src.['+@col+'],'; END;
    END /* WHILE */ DROP TABLE IF EXISTS #busineskeys; 
    SET @pks = @bks + ' "|", ' + @frm + ', "|")' + @nwl + '))';
    SET @bks += '"|")' + @nwl + '))';
    
    SET @rwh = REPLACE(@rwh, @nwl, @nwl + '                       ');
    SET @pks = REPLACE(@pks, @nwl, @nwl + '                       ');
    SET @bks = REPLACE(@bks, @nwl, @nwl + '                       ');

  END

  SET @tx_message = '-- Drop view for gathering "metadata"-attributes.';
  SET @tx_sql = 'DROP VIEW IF EXISTS tsa_' + @ip_nm_target_schema + '.get_' + @ip_nm_target_table;
  EXEC gnc_commen.show_and_execute_sql @tx_message, @tx_sql, @ip_is_debugging, @ip_is_testing;
  
  SET @tx_message = '-- Create view for gathering "metadata"-attributes.';
  SET @tx_sql  = @emp + 'CREATE VIEW tsa_' + @ip_nm_target_schema + '.get_' + @ip_nm_target_table + ' AS SELECT *, ';
  SET @tx_sql += @nwl + '  meta_dt_valid_from = CONVERT(DATETIME, ' + @frm + '),';
  SET @tx_sql += @nwl + '  meta_dt_valid_till = CONVERT(DATETIME, ' + @tll + '),';
  SET @tx_sql += @nwl + '  meta_is_active     = CONVERT(BIT,      1),';
  SET @tx_sql += @nwl + '  meta_ch_rh         = CONVERT(CHAR(32), HASHBYTES("MD5", ' + @rwh + ', 2),';
  SET @tx_sql += @nwl + '  meta_ch_bk         = CONVERT(CHAR(32), HASHBYTES("MD5", ' + @bks + ', 2),';
  SET @tx_sql += @nwl + '  meta_ch_pk         = CONVERT(CHAR(32), HASHBYTES("MD5", ' + @pks + ', 2)';
  SET @tx_sql += @nwl + 'FROM tsa_' + @ip_nm_target_schema + '.tsa_' + @ip_nm_target_table + ' AS src';
  SET @tx_sql = REPLACE(@tx_sql,'"', '''');
  EXEC gnc_commen.show_and_execute_sql @tx_message, @tx_sql, @ip_is_debugging, @ip_is_testing;

END
GO