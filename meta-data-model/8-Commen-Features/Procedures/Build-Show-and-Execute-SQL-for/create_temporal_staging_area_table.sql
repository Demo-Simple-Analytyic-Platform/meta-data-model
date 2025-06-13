CREATE PROCEDURE mdm.create_temporal_staging_area_table

  /* Input Parameters */
  @ip_id_model         CHAR(32),
  @ip_id_dataset       CHAR(32),
  @ip_nm_target_schema NVARCHAR(128),
  @ip_nm_target_table  NVARCHAR(128),

  /* Input Paramters for "Debugging". */
  @ip_is_debugging     BIT = 0,
  @ip_is_testing       BIT = 0

AS DECLARE

  @is_dataset_found BIT           = ISNULL((SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @ip_nm_target_schema AND TABLE_NAME = @ip_nm_target_table), 0),
  @is_sql_source    BIT           = IIF(LOWER(gnc_commen.tx_parameter_value(@ip_id_model, @ip_id_dataset, 'adf_2_cd_source_dataset_type')) = 'sql', 1, 0),
  @tx_sql           NVARCHAR(MAX) = '',
  @tx_etl           NVARCHAR(MAX) = '',
  @tx_ddl           NVARCHAR(MAX) = '',
  @tx_message       NVARCHAR(999),
  @ni_ordering      INT;

BEGIN

  IF (1=1 /* Extract "Columns"-dataset, exclude the "meta-attributes. */) BEGIN
    
    DROP TABLE IF EXISTS ##columns; SELECT 
      ni_ordering = att.ni_ordering,
      tx_ddl = '  [' + att.nm_target_column + '] ' + dtp.cd_target_datatype + ',' + CHAR(10)
  
    INTO ##columns 
  
    FROM dta.attribute AS att

    JOIN dta.dataset   AS dst 
    ON  dst.meta_is_active   = 1 
    AND dst.id_model         = att.id_model
    AND dst.id_dataset       = att.id_dataset 
    
    JOIN srd.datatype  AS dtp 
    ON  dtp.meta_is_active = 1 
    AND dtp.id_model       = att.id_model
    AND dtp.id_datatype    = att.id_datatype

    WHERE att.meta_is_active = 1 
    AND   att.id_model       = @ip_id_model
    AND   att.id_dataset     = @ip_id_dataset
    AND   att.nm_target_column NOT IN ('meta_dt_valid_from', 'meta_dt_valid_till', 'meta_is_active', 'meta_ch_rh', 'meta_ch_bk', 'meta_ch_pk', 'meta_dt_created')
    ORDER BY ni_ordering ASC;

  END
  
  IF (1=1 /* String all the "Colums" in the "temp"-table together with "s."-alias, after drop the "temp"-table. */) BEGIN

    WHILE ((SELECT COUNT(*) FROM ##columns) > 0) BEGIN 
      SELECT @tx_ddl += tx_ddl, @ni_ordering = ni_ordering FROM (SELECT TOP 1 * FROM ##columns ORDER BY ni_ordering) AS rec; 
      DELETE FROM ##columns WHERE ni_ordering = @ni_ordering; 
    END /* WHILE */ DROP TABLE IF EXISTS ##columns; 

    /* Add meta-attributes */ 
    SET @tx_etl += '  [meta_dt_valid_from] DATETIME NOT NULL,' + CHAR(10);
    SET @tx_etl += '  [meta_dt_valid_till] DATETIME NOT NULL,' + CHAR(10);
    SET @tx_etl += '  [meta_is_active]     BIT      NOT NULL,' + CHAR(10);
    SET @tx_etl += '  [meta_ch_rh]         CHAR(32) NOT NULL,' + CHAR(10);
    SET @tx_etl += '  [meta_ch_bk]         CHAR(32) NOT NULL,' + CHAR(10);
    SET @tx_etl += '  [meta_ch_pk]         CHAR(32) NOT NULL,' + CHAR(10);
    SET @tx_etl += '  [meta_dt_created]    DATETIME NOT NULL DEFAULT GETDATE()'  + CHAR(10);

  END

  IF (@is_dataset_found = 0 /* Extract "temp"-table with Columns of "Target"-table, exclude the "meta-attributes. */) BEGIN
   
    /* Show and Execute SQL Statements */
    SET @tx_message = '-- SQL code for "Creating" table "' + @ip_nm_target_schema + '"."' + @ip_nm_target_table + '".';
    SET @tx_sql = 'CREATE TABLE [' + @ip_nm_target_schema + '].[' + @ip_nm_target_table + '] (' + CHAR(10) + @tx_ddl + @tx_etl + ')';
    EXEC gnc_commen.show_and_execute_sql @tx_message, @tx_sql, @ip_is_debugging, @ip_is_testing;

    /* Make the table Columnstore */
    EXEC mdm.create_column_store_index @ip_nm_target_schema, @ip_nm_target_table, @ip_is_debugging, @ip_is_testing;

  END

  IF (1=1 /* Create "Temporal Staging Area"-table. */) BEGIN

    /* Build SQL "Creation" of " Dataset. */
    SET @tx_message = '-- SQL code for "Dropping" previous version of "Temporal Staging Area"-table of ' + @ip_nm_target_schema + '"."' + @ip_nm_target_table + '".';
    SET @tx_sql     = 'DROP TABLE IF EXISTS [tsa_' + @ip_nm_target_schema + '].[tsa_' + @ip_nm_target_table + ']';
    EXEC gnc_commen.show_and_execute_sql @tx_message, @tx_sql, @ip_is_debugging, @ip_is_testing;
    
    /* Build SQL "Creation" of " Dataset. */
    SET @tx_message = '-- SQL code for "Creating" a "Temporal Staging Area"-table for' + @ip_nm_target_schema + '"."' + @ip_nm_target_table + '".';
    SET @tx_sql = 'CREATE TABLE [tsa_' + @ip_nm_target_schema + '].[tsa_' + @ip_nm_target_table + '] ('+ @tx_ddl + @tx_etl + ')'; 
    EXEC gnc_commen.show_and_execute_sql @tx_message, @tx_sql, @ip_is_debugging, @ip_is_testing;

  END

  IF (@is_sql_source = 0 /* Create "Temporal Staging Landing"-table. */) BEGIN

    /* Build SQL "Creation" of " Dataset. */
    SET @tx_message = '-- SQL code for "Dropping" previous version of "Temporal Staging Landing"-table of ' + @ip_nm_target_schema + '"."' + @ip_nm_target_table + '".';
    SET @tx_sql     = 'DROP TABLE IF EXISTS [tsl_' + @ip_nm_target_schema + '].[tsl_' + @ip_nm_target_table + ']';
    EXEC gnc_commen.show_and_execute_sql @tx_message, @tx_sql, @ip_is_debugging, @ip_is_testing;
    
    /* Build SQL "Creation" of " Dataset. */
    SET @tx_message = '-- SQL code for "Creating" a "Temporal Staging Landing"-table for' + @ip_nm_target_schema + '"."' + @ip_nm_target_table + '".';
    SET @tx_sql = CHAR(10) + SUBSTRING(@tx_ddl, 1, (LEN(@tx_ddl)-2)) + CHAR(10); -- removing the "last" ","-character.
    SET @tx_sql = 'CREATE TABLE [tsl_' + @ip_nm_target_schema + '].[tsl_' + @ip_nm_target_table + '] ('+ @tx_sql + ')'; 
    EXEC gnc_commen.show_and_execute_sql @tx_message, @tx_sql, @ip_is_debugging, @ip_is_testing;

  END
  RETURN 0

END
GO