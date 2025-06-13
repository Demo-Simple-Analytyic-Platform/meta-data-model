CREATE PROCEDURE deployment.usp_create_tsa
  
  /* Input Parameters */
  @ip_nm_schema NVARCHAR(128) = 'srd',
  @ip_nm_table  NVARCHAR(128) = 'dq_risk_level'

AS DECLARE /* Local Variables */
  @sql NVARCHAR(MAX);

BEGIN
  
  SET @sql = 'DROP TABLE IF EXISTS tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table; 
  EXEC sp_executesql @sql;
  
  SET @sql = 'SELECT * INTO        tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' '
           + 'FROM [' + @ip_nm_schema + '].[' + @ip_nm_table + '] ' 
           + 'WHERE ' + CASE WHEN @ip_nm_table LIKE 'transformation_%'      THEN 'meta_is_active = 1'
                             WHEN @ip_nm_table    = 'dq_involved_attribute' THEN 'meta_is_active = 1'
                             ELSE '1 = 2'
                        END; 
  EXEC sp_executesql @sql;
  
  SET @sql = 'ALTER TABLE          tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' DROP COLUMN meta_dt_valid_from'; EXEC sp_executesql @sql;
  SET @sql = 'ALTER TABLE          tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' DROP COLUMN meta_dt_valid_till'; EXEC sp_executesql @sql;
  SET @sql = 'ALTER TABLE          tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' DROP COLUMN meta_is_active';     EXEC sp_executesql @sql;
  SET @sql = 'ALTER TABLE          tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' DROP COLUMN meta_ch_rh';         EXEC sp_executesql @sql;
  SET @sql = 'ALTER TABLE          tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' DROP COLUMN meta_ch_bk';         EXEC sp_executesql @sql;
  SET @sql = 'ALTER TABLE          tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' DROP COLUMN meta_ch_pk';         EXEC sp_executesql @sql;
  SET @sql = 'ALTER TABLE          tsa_' + @ip_nm_schema + '.tsa_' + @ip_nm_table + ' DROP COLUMN meta_dt_created';    EXEC sp_executesql @sql;
END
GO