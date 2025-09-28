CREATE PROCEDURE mdm.create_user_specified_procedure

  /* Input Parameters */
  @ip_id_model         CHAR(32),
  @ip_nm_target_schema NVARCHAR(128),
  @ip_nm_target_table  NVARCHAR(128),

  /* Input Paramters for "Debugging". */
  @ip_is_debugging     BIT = 0,
  @ip_is_testing       BIT = 0

AS DECLARE /* Local Variables */
  
  @id_dataset           CHAR(32) = (SELECT id_dataset 
                                    FROM dta.dataset 
                                    WHERE meta_is_active = 1 
                                    AND nm_target_schema = @ip_nm_target_schema 
                                    AND nm_target_table  = @ip_nm_target_table 
                                    AND id_model         = @ip_id_model);

DECLARE
  @ni_ordering          INT,
  @nm_target_column     NVARCHAR(128),
  @is_businesskey       BIT,
  @is_ingestion         BIT,
  @nm_data_flow_type         NVARCHAR(128),
  @tx_query_source      NVARCHAR(MAX) = '',
  @tx_query_update      NVARCHAR(MAX) = '',
  @tx_query_insert      NVARCHAR(MAX) = '',
  @tx_query_calculation NVARCHAR(MAX) = '',
  @tx_query_procedure   NVARCHAR(MAX) = '',
  @tx_pk_fields         NVARCHAR(MAX) = '',
  @tx_attributes        NVARCHAR(MAX) = '',
  @tx_message           NVARCHAR(MAX) = '',
  @tx_procedure         NVARCHAR(MAX) = '',
  @tx_sql               NVARCHAR(MAX) = '',

  @nwl NVARCHAR(1)   = CHAR(10),
  @emp NVARCHAR(1)   = '',
  @sql NVARCHAR(MAX) = '',
  
  @tsa NVARCHAR(MAX),
  @src NVARCHAR(MAX),
  @tgt NVARCHAR(MAX),
  @col NVARCHAR(MAX) = '',
  @att NVARCHAR(MAX) = '',
  @qry NVARCHAR(MAX) = '',   
  
  @sqt NVARCHAR(1)   = '''',
  @ddl NVARCHAR(MAX) = '',
  @tb1 NVARCHAR(32)  = CHAR(10) + '  ',
  @tb2 NVARCHAR(32)  = CHAR(10) + '    ',
  @tb3 NVARCHAR(32)  = CHAR(10) + '      ',
  
  /* Local Varaibles for "SQL" for "Metadata"-attributes. */
  @nm_processing_type            NVARCHAR(128),
  @tx_sql_for_meta_dt_valid_from NVARCHAR(MAX),
  @tx_sql_for_meta_dt_valid_till NVARCHAR(MAX),
  
  /* "Transformation"-helper for filtering the "Incremental"-resultset. */
  @is_full_join_used            BIT,
  @is_union_join_used           BIT,
  @tx_sql_main_where_statement  NVARCHAR(MAX),

  /* "Transformation"-parts */
--  @tx_sql_attribute             NVARCHAR(MAX),
--  @is_aggregate_function_used   BIT,
        
  /* "Transformation"-datasets */
--  @id_transformation_dataset       CHAR(32),
--  @tx_sql_for_replace_from_dataset NVARCHAR(MAX),
--  @cd_alias_for_from               NVARCHAR(MAX),
--  @cd_alias_for_full_join          NVARCHAR(MAX),

  /* Local Variables for "Timestamp/Epoch". */
  @dt_previous_stand NVARCHAR(32),
  @dt_current_stand  NVARCHAR(32),
  @ni_previous_epoch NVARCHAR(32),
  @ni_current_epoch  NVARCHAR(32),
  @tx_sql_between    NVARCHAR(MAX) = 'BETWEEN CONVERT(DATETIME, @dt_previous_stand) AND CONVERT(DATETIME, @dt_current_stand)',

  /* Local Varaibles for "SQL" for "Metadata"-attributes. */
  @rwh NVARCHAR(MAX) = '',
  @bks NVARCHAR(MAX) = '',
  @pks NVARCHAR(MAX) = '',
  @ord INT,
  @idx INT = 0,
  @max INT = 100

BEGIN

  /* Turn off Effected Row */
  SET NOCOUNT ON;
   
  /* Turn off Warnings */
  SET ANSI_WARNINGS OFF;

  IF (1=1 /* Extract schema and Table. */) BEGIN
    
    SELECT @tsa = '[tsa_' + dst.nm_target_schema + '].[tsa_' + dst.nm_target_table + ']',
           @src = '[tsa_' + dst.nm_target_schema + '].[tsa_' + dst.nm_target_table + ']',
           @tgt = '[' +     dst.nm_target_schema + '].['     + dst.nm_target_table + ']',
           @is_ingestion = dst.is_ingestion,
           @nm_data_flow_type = CASE WHEN dst.is_ingestion = 1 THEN 'Ingestion' ELSE 'Transformation' END,
           @tx_query_source = REPLACE(dst.tx_source_query, '<newline>', @nwl),
           @nm_processing_type            = IIF(dst.nm_target_schema = 'dq_totals', 'Fullload', etl.nm_processing_type),
           @tx_sql_for_meta_dt_valid_from = REPLACE(ISNULL(etl.tx_sql_for_meta_dt_valid_from,'n/a'), @sqt, '"'),
           @tx_sql_for_meta_dt_valid_till = REPLACE(ISNULL(etl.tx_sql_for_meta_dt_valid_till,'n/a'), @sqt, '"')
    FROM dta.dataset AS dst LEFT JOIN dta.ingestion_etl AS etl ON etl.meta_is_active = 1 AND etl.id_dataset = dst.id_dataset AND etl.id_model = dst.id_model
    WHERE dst.meta_is_active = 1 
    AND   dst.id_dataset     = @id_dataset
    AND   dst.id_model       = @ip_id_model;

  END

  IF (1=1 /* Extract Column information */) BEGIN
  
    /* Extract "temp"-table with Columns of "Target"-table, exclude the "meta-attributes. */
    DROP TABLE IF EXISTS ##columns; 
    SELECT ni_ordering, 
           is_businesskey, 
           nm_target_column
    INTO ##columns 
    FROM dta.attribute
    WHERE meta_is_active = 1 AND nm_target_column NOT IN ('meta_dt_valid_from', 'meta_dt_valid_till', 'meta_is_active', 'meta_ch_rh', 'meta_ch_bk', 'meta_ch_pk')
    AND   id_dataset = @id_dataset 
    AND   id_model   = @ip_id_model
    ORDER BY ni_ordering ASC;

    /* String all the "Colums" in the "temp"-table together with "s."-alias, after drop the "temp"-table. */
    WHILE ((SELECT COUNT(*) FROM ##columns) > 0) BEGIN 
      SELECT @ni_ordering      = ni_ordering,
             @is_businesskey   = is_businesskey,
             @nm_target_column = nm_target_column
      FROM (SELECT TOP 1 * FROM ##columns ORDER BY ni_ordering ASC) AS rec; 
      DELETE FROM ##columns WHERE ni_ordering = @ni_ordering; 
      SET @tx_attributes += 's.[' + @nm_target_column + '], '; 
      SET @tx_pk_fields  += IIF(@is_businesskey = 1, ', s.[' + @nm_target_column + '], "|"', ''); 
    END /* WHILE */ DROP TABLE IF EXISTS ##columns; 

  END

  IF (1=1 /* Extrent then "Source"-query with metadata-attributes so is can load data into "TSA"-table. */) BEGIN

    IF (1=1 /* Extract "Columns"-dataset, exclude the "meta-attributes. */) BEGIN
    
      DROP TABLE IF EXISTS #columns; SELECT 
        o = att.ni_ordering,
        c = att.nm_target_column 
      INTO #columns FROM dta.attribute AS att
      WHERE att.id_dataset     = @id_dataset
      AND   att.id_model       = @ip_id_model
      AND   att.meta_is_active = 1 AND nm_target_column NOT IN ('meta_dt_valid_from', 'meta_dt_valid_till', 'meta_is_active', 'meta_ch_rh', 'meta_ch_bk', 'meta_ch_pk')
      ORDER BY ni_ordering ASC;
    
      DROP TABLE IF EXISTS #busineskeys; SELECT 
        o = att.ni_ordering,
        c = att.nm_target_column 
      INTO #busineskeys FROM dta.attribute AS att 
      WHERE att.id_dataset     = @id_dataset
      AND   att.id_model       = @ip_id_model
      AND   att.meta_is_active = 1 AND nm_target_column NOT IN ('meta_dt_valid_from', 'meta_dt_valid_till', 'meta_is_active', 'meta_ch_rh', 'meta_ch_bk', 'meta_ch_pk')
      AND   att.is_businesskey = 1
      ORDER BY ni_ordering ASC;

      IF (@ip_is_debugging=1) BEGIN SELECT * FROM #columns; END;
      IF (@ip_is_debugging=1) BEGIN SELECT * FROM #busineskeys; END;

    END
    IF (1=1 /* String all the "Colums" in the "temp"-table together with "s."-alias, after drop the "temp"-table. */) BEGIN
    
      /* Build SQL Statment for Column "meta_ch_rh. */
      SET @rwh += 'CONCAT(CONVERT(NVARCHAR(MAX), ""),'+ @nwl + '  CONCAT(';
      SET @idx = 0; WHILE ((SELECT COUNT(*) FROM #columns) > 0) BEGIN 
        SELECT @col=c, @ord=o FROM (SELECT TOP 1 * FROM #columns ORDER BY o ASC) AS rec; 
        DELETE FROM #columns WHERE o = @ord; 
        SET @att += '[main].[' + @col + '] AS [' + @col + '],' + @nwl;
        IF (@idx = @max) BEGIN SET @idx += 1; SET @rwh += '"|")'; END;
        IF (@idx > @max) BEGIN SET @idx  = 0; SET @rwh += ',' + @nwl + '  CONCAT(';END;
        IF (@idx < @max) BEGIN SET @idx += 1; SET @rwh += ' "|", [main].['+@col+'],'; END;
      END /* WHILE */ DROP TABLE IF EXISTS #columns; 
      SET @rwh += '"|")' + @nwl + '))';

      /* Build SQL Statment for Column "meta_ch_bk"  and "meta_ch_pk". */
      SET @bks += 'CONCAT(CONVERT(NVARCHAR(MAX), ""),'+ @nwl + '  CONCAT(';
      SET @idx = 0; WHILE ((SELECT COUNT(*) FROM #busineskeys) > 0) BEGIN 
        SELECT @col=c, @ord=o FROM (SELECT TOP 1 * FROM #busineskeys ORDER BY o ASC) AS rec; 
        DELETE FROM #busineskeys WHERE o = @ord; 
        IF (@idx = @max) BEGIN SET @idx += 1; SET @bks += '"|")'; END;
        IF (@idx > @max) BEGIN SET @idx  = 0; SET @bks += ',' + @nwl + '  CONCAT(';END;
        IF (@idx < @max) BEGIN SET @idx += 1; SET @bks += ' "|", [main].['+@col+'],'; END;
      END /* WHILE */ DROP TABLE IF EXISTS #busineskeys; 
      SET @pks = @bks + ' "|", [main].[meta_dt_valid_from], "|")' + @nwl + '))';
      SET @bks += '"|")' + @nwl + '))';
    
      SET @rwh = REPLACE(@rwh, @nwl, @nwl + '                       ');
      SET @pks = REPLACE(@pks, @nwl, @nwl + '                       ');
      SET @bks = REPLACE(@bks, @nwl, @nwl + '                       ');
      
      IF (@ip_is_debugging=1) BEGIN 
        PRINT(@rwh);
        PRINT(@pks);
        PRINT(@bks);
      END

    END  

    IF (@ip_is_debugging=1) BEGIN PRINT('@is_ingestion : ' + CONVERT(NVARCHAR(1), @is_ingestion)); END;
    IF (@is_ingestion = 1 /* Extent the "Source"-query */) BEGIN

      /* Build SQL Statment for "Ingestion"  to handle the "TSL"-table. in correct and desired way. */
      SET @qry = REPLACE(@tx_query_source, @nwl, @tb1);
      SET @idx = CHARINDEX('FROM', @tx_query_source, 1);
      SET @qry  = @emp + 'SELECT';
      SET @qry += @nwl + '  ' + REPLACE(@att, @nwl, @tb1);
      SET @qry += @emp +   '[main].[meta_dt_valid_from] AS [meta_dt_valid_from],';
      SET @qry += @nwl + '  [main].[meta_dt_valid_till] AS [meta_dt_valid_till],';
      SET @qry += @nwl + '  CONVERT(BIT, 1) AS [meta_is_active],';
      SET @qry += @nwl + '  CONVERT(CHAR(32), HASHBYTES("MD5", ' + @rwh + ', 2) AS [meta_ch_rh],';
      SET @qry += @nwl + '  CONVERT(CHAR(32), HASHBYTES("MD5", ' + @bks + ', 2) AS [meta_ch_bk],';
      SET @qry += @nwl + '  CONVERT(CHAR(32), HASHBYTES("MD5", ' + @pks + ', 2) AS [meta_ch_pk]';
      SET @qry += @nwl + 'FROM (';
      SET @qry += @nwl + '  ' + SUBSTRING(@tx_query_source, 1, @idx-1);
      SET @qry += @nwl + '  , meta_dt_valid_from = CONVERT(DATETIME, ' + @tx_sql_for_meta_dt_valid_from + ')';
      SET @qry += @nwl + '  , meta_dt_valid_till = CONVERT(DATETIME, ' + @tx_sql_for_meta_dt_valid_till + ')';
      SET @qry += @nwl + '  ' + SUBSTRING(@tx_query_source, @idx, LEN(@tx_query_source));
      SET @qry += @nwl + ') AS [main]';

      /* Show SQL Statement for "Ingestion" if in Debugging mode. */
      IF (@ip_is_debugging=1) BEGIN 
        PRINT('/* Extent the "Source"-query */');
        EXEC gnc_commen.to_concol_window @qry;
      END
    END
    IF (@is_ingestion = 0 /* Extent the "Transformation"-query */) BEGIN 
      
      IF (@ip_is_debugging=1) BEGIN PRINT('/* Extent the "Transformation"-query */'); END
    
      IF (1=1 /* Extract "Parts" for the "Transformations". */) BEGIN

        /* Add "Transformation"-parts to the "Source"-query. */
        DROP TABLE IF EXISTS #prt; SELECT prt.* INTO #prt FROM (SELECT 
          
          /*  Model/Dataset and Source Query */
          dst.id_model,
          dst.id_dataset,
          dst.tx_source_query,

          /* ETL logic */
          etl.nm_processing_type,
          etl.tx_sql_for_meta_dt_valid_from,
          etl.tx_sql_for_meta_dt_valid_till,
          CASE -- AS is_aggregate_function_used_valid_from,
            WHEN CHARINDEX('COUNT(',        UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_from, ' ', '')), 1) > 0 THEN 1
            WHEN CHARINDEX('SUM(',          UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_from, ' ', '')), 1) > 0 THEN 1 
            WHEN CHARINDEX('AVG(',          UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_from, ' ', '')), 1) > 0 THEN 1 
            WHEN CHARINDEX('MAX(',          UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_from, ' ', '')), 1) > 0 THEN 1 
            WHEN CHARINDEX('MIN(',          UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_from, ' ', '')), 1) > 0 THEN 1 
            WHEN CHARINDEX('STDEV(',        UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_from, ' ', '')), 1) > 0 THEN 1
            WHEN CHARINDEX('STDEVP(',       UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_from, ' ', '')), 1) > 0 THEN 1
            WHEN CHARINDEX('VAR(',          UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_from, ' ', '')), 1) > 0 THEN 1 
            WHEN CHARINDEX('VARP(',         UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_from, ' ', '')), 1) > 0 THEN 1
            WHEN CHARINDEX('GROUPING(',     UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_from, ' ', '')), 1) > 0 THEN 1
            WHEN CHARINDEX('CHECKSUM_AGG(', UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_from, ' ', '')), 1) > 0 THEN 1
            WHEN CHARINDEX('STRING_AGG(',   UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_from, ' ', '')), 1) > 0 THEN 1
            WHEN CHARINDEX('JSON_AGG(',     UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_from, ' ', '')), 1) > 0 THEN 1
            ELSE 0 
          END AS is_aggregate_function_used_valid_from,
          CASE -- AS is_aggregate_function_used_valid_from,
            WHEN CHARINDEX('COUNT(',        UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_till, ' ', '')), 1) > 0 THEN 1
            WHEN CHARINDEX('SUM(',          UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_till, ' ', '')), 1) > 0 THEN 1 
            WHEN CHARINDEX('AVG(',          UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_till, ' ', '')), 1) > 0 THEN 1 
            WHEN CHARINDEX('MAX(',          UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_till, ' ', '')), 1) > 0 THEN 1 
            WHEN CHARINDEX('MIN(',          UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_till, ' ', '')), 1) > 0 THEN 1 
            WHEN CHARINDEX('STDEV(',        UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_till, ' ', '')), 1) > 0 THEN 1
            WHEN CHARINDEX('STDEVP(',       UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_till, ' ', '')), 1) > 0 THEN 1
            WHEN CHARINDEX('VAR(',          UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_till, ' ', '')), 1) > 0 THEN 1 
            WHEN CHARINDEX('VARP(',         UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_till, ' ', '')), 1) > 0 THEN 1
            WHEN CHARINDEX('GROUPING(',     UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_till, ' ', '')), 1) > 0 THEN 1
            WHEN CHARINDEX('CHECKSUM_AGG(', UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_till, ' ', '')), 1) > 0 THEN 1
            WHEN CHARINDEX('STRING_AGG(',   UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_till, ' ', '')), 1) > 0 THEN 1
            WHEN CHARINDEX('JSON_AGG(',     UPPER(REPLACE(etl.tx_sql_for_meta_dt_valid_till, ' ', '')), 1) > 0 THEN 1
            ELSE 0 
          END AS is_aggregate_function_used_valid_till,

          /* Transformation Part(s) */
          tpt.id_transformation_part,
          tpt.ni_transformation_part,
          tpt.tx_transformation_part,
          tpt.is_aggregate_function_used,
  
          TRIM(SUBSTRING(tx_transformation_part, 1, (tpt.ni_pos_from - 1))) AS tx_sql_select,
          CASE /* AS tx_sql_from */
            WHEN tpt.ni_pos_from != 0 AND tpt.ni_pos_where    != 0  THEN SUBSTRING(tx_transformation_part, tpt.ni_pos_from, (tpt.ni_pos_where       - tpt.ni_pos_from))
            WHEN tpt.ni_pos_from != 0 AND tpt.ni_pos_group_by != 0  THEN SUBSTRING(tx_transformation_part, tpt.ni_pos_from, (tpt.ni_pos_group_by    - tpt.ni_pos_from))
            WHEN tpt.ni_pos_from != 0                               THEN SUBSTRING(tx_transformation_part, tpt.ni_pos_from, (tpt.ni_length          - tpt.ni_pos_from))
            ELSE '' 
          END AS tx_sql_from,
          CASE /* AS tx_sql_where */ 
            WHEN tpt.ni_pos_where != 0 AND tpt.ni_pos_group_by != 0 THEN SUBSTRING(tx_transformation_part, tpt.ni_pos_where, (tpt.ni_pos_group_by   - tpt.ni_pos_where))
            WHEN tpt.ni_pos_where != 0 AND tpt.ni_pos_having   != 0 THEN SUBSTRING(tx_transformation_part, tpt.ni_pos_where, (tpt.ni_pos_having     - tpt.ni_pos_where))
            WHEN tpt.ni_pos_where != 0                              THEN SUBSTRING(tx_transformation_part, tpt.ni_pos_where, (tpt.ni_length         - tpt.ni_pos_where))
            ELSE ''
          END AS tx_sql_where,
          CASE /* AS tx_sql_group_by */
            WHEN tpt.ni_pos_group_by != 0 AND tpt.ni_pos_having != 0 THEN SUBSTRING(tx_transformation_part, tpt.ni_pos_group_by, (tpt.ni_pos_having - tpt.ni_pos_group_by))
            WHEN tpt.ni_pos_group_by != 0                            THEN SUBSTRING(tx_transformation_part, tpt.ni_pos_group_by, (tpt.ni_length     - tpt.ni_pos_group_by))
            ELSE ''
          END AS tx_sql_group_by,
          CASE /* AS tx_sql_having */
            WHEN tpt.ni_pos_having != 0                              THEN SUBSTRING(tx_transformation_part, tpt.ni_pos_having, (tpt.ni_length       - tpt.ni_pos_having))
            ELSE ''
          END AS tx_sql_having
        
        FROM dta.dataset as dst JOIN ( -- Transformation Part
          SELECT 
            id_model,
            id_dataset,
            id_transformation_part,
            ni_transformation_part,
            tx_transformation_part,
            is_aggregate_function_used = CASE
                  WHEN CHARINDEX('COUNT(',        UPPER(REPLACE(tx_transformation_part, ' ', '')), 1) > 0 THEN 1
                  WHEN CHARINDEX('SUM(',          UPPER(REPLACE(tx_transformation_part, ' ', '')), 1) > 0 THEN 1 
                  WHEN CHARINDEX('AVG(',          UPPER(REPLACE(tx_transformation_part, ' ', '')), 1) > 0 THEN 1 
                  WHEN CHARINDEX('MAX(',          UPPER(REPLACE(tx_transformation_part, ' ', '')), 1) > 0 THEN 1 
                  WHEN CHARINDEX('MIN(',          UPPER(REPLACE(tx_transformation_part, ' ', '')), 1) > 0 THEN 1 
                  WHEN CHARINDEX('STDEV(',        UPPER(REPLACE(tx_transformation_part, ' ', '')), 1) > 0 THEN 1
                  WHEN CHARINDEX('STDEVP(',       UPPER(REPLACE(tx_transformation_part, ' ', '')), 1) > 0 THEN 1
                  WHEN CHARINDEX('VAR(',          UPPER(REPLACE(tx_transformation_part, ' ', '')), 1) > 0 THEN 1 
                  WHEN CHARINDEX('VARP(',         UPPER(REPLACE(tx_transformation_part, ' ', '')), 1) > 0 THEN 1
                  WHEN CHARINDEX('GROUPING(',     UPPER(REPLACE(tx_transformation_part, ' ', '')), 1) > 0 THEN 1
                  WHEN CHARINDEX('CHECKSUM_AGG(', UPPER(REPLACE(tx_transformation_part, ' ', '')), 1) > 0 THEN 1
                  WHEN CHARINDEX('STRING_AGG(',   UPPER(REPLACE(tx_transformation_part, ' ', '')), 1) > 0 THEN 1
                  WHEN CHARINDEX('JSON_AGG(',     UPPER(REPLACE(tx_transformation_part, ' ', '')), 1) > 0 THEN 1
                  ELSE 0 
            END,
            /* Calculating postion on FROM, WHERE, GROUP BY and/or HAVING. */
            ni_pos_from     = CHARINDEX('FROM',      tx_transformation_part, 1),
            ni_pos_where    = CHARINDEX('WHERE',     tx_transformation_part, 1),
            ni_pos_group_by = CHARINDEX('GROUP BY',  tx_transformation_part, 1),
            ni_pos_having   = CHARINDEX('HAVING',    tx_transformation_part, 1),
            ni_length       = LEN(tx_transformation_part) + 1 /* !!! Otherwise the substring at the end will miss 1 character !!! */
          FROM dta.transformation_part
          WHERE meta_is_active = 1 
        ) AS tpt
        ON  tpt.id_model   = dst.id_model
        AND tpt.id_dataset = dst.id_dataset
        
        LEFT JOIN dta.ingestion_etl AS etl
        ON  etl.meta_is_active = 1 
        AND etl.id_model   = tpt.id_model
        AND etl.id_dataset = tpt.id_dataset 
        
        WHERE dst.meta_is_active = 1
        AND   dst.fn_dataset    != 'dummy'
        AND   dst.is_ingestion  != 1 

        /* Filtering the "Transformation"-parts by "Model" and "Dataset". */
        AND   tpt.id_model     = @ip_id_model
        AND   tpt.id_dataset   = @id_dataset
        ) AS prt;
  
        /* Declare index part and max */
        DECLARE @ni_prt INT = 1, @mx_prt INT = (SELECT MAX(ni_transformation_part) FROM #prt),

          /* Declare "Transformation"-part variables. */
          @is_aggregate_function_used            BIT,
          @is_utilized_column_used_in_valid_from BIT,
          @is_utilized_column_used_in_valid_till BIT,
          @is_aggregate_function_used_valid_from BIT,
          @is_aggregate_function_used_valid_till BIT,
  
          @tx_sql_select              NVARCHAR(MAX),
          @tx_sql_from                NVARCHAR(MAX),
          @tx_sql_where               NVARCHAR(MAX),
          @tx_sql_group_by            NVARCHAR(MAX),
          @tx_sql_having              NVARCHAR(MAX)

        /* If IN DEBUG mode, show the "Transformation"-parts. */
        IF (@ip_is_debugging=1) BEGIN SELECT * FROM #prt; END;

      END

      IF (1=1 /* Build SQL Statement for the "Source" query. */) BEGIN

        IF (1=1 /* Build SQL Statement for the "Source" query, relavant to the "main"-wrapper. */) BEGIN
          SET @idx = CHARINDEX('FROM', @tx_query_source, 1);
          SET @qry  = @emp + 'SELECT';
          SET @qry += @nwl + '  ' + REPLACE(@att, @nwl, @tb1);
          SET @qry += @emp +   '[main].[meta_dt_valid_from] AS [meta_dt_valid_from],';
          SET @qry += @nwl + '  [main].[meta_dt_valid_till] AS [meta_dt_valid_till],';
          SET @qry += @nwl + '  CONVERT(BIT, 1) AS [meta_is_active],';
          SET @qry += @nwl + '  CONVERT(CHAR(32), HASHBYTES("MD5", ' + @rwh + ', 2) AS [meta_ch_rh],';
          SET @qry += @nwl + '  CONVERT(CHAR(32), HASHBYTES("MD5", ' + @bks + ', 2) AS [meta_ch_bk],';
          SET @qry += @nwl + '  CONVERT(CHAR(32), HASHBYTES("MD5", ' + @pks + ', 2) AS [meta_ch_pk]';
          SET @qry += @nwl + 'FROM ( -- "' + @nm_processing_type +'" processing mode.';
        END 

        /* Loop throught all the "Transformation"-parts and build the "Source"-query. */
        WHILE (@ni_prt <= @mx_prt) BEGIN

          /* Extract the "Transformation"-part */
          SELECT @tx_sql_select                         = prt.tx_sql_select 
                , @tx_sql_from                           = prt.tx_sql_from 
                , @tx_sql_where                          = prt.tx_sql_where
                , @tx_sql_group_by                       = prt.tx_sql_group_by 
                , @tx_sql_having                         = prt.tx_sql_having
                , @is_aggregate_function_used            = prt.is_aggregate_function_used
                , @tx_sql_for_meta_dt_valid_from         = prt.tx_sql_for_meta_dt_valid_from
                , @tx_sql_for_meta_dt_valid_till         = prt.tx_sql_for_meta_dt_valid_till
                , @is_aggregate_function_used_valid_from = prt.is_aggregate_function_used_valid_from
                , @is_aggregate_function_used_valid_till = prt.is_aggregate_function_used_valid_till
          FROM #prt AS prt
          WHERE ni_transformation_part = @ni_prt;

          /* Determing if the "Transformation"-part is using a "Source"-attributes in ETL valid from/till definitons. */
          SELECT @is_utilized_column_used_in_valid_from = SUM(CASE WHEN etl.tx_sql_for_meta_dt_valid_from LIKE '%' + col.nm_target_column + '%' THEN 1 ELSE 0 END) 
                , @is_utilized_column_used_in_valid_till = SUM(CASE WHEN etl.tx_sql_for_meta_dt_valid_till LIKE '%' + col.nm_target_column + '%' THEN 1 ELSE 0 END) 
          FROM      dta.transformation_part      AS prt
          LEFT JOIN dta.transformation_mapping   AS map ON map.meta_is_active = 1 AND map.id_transformation_part    = prt.id_transformation_part
          LEFT JOIN dta.transformation_attribute AS att ON att.meta_is_active = 1 AND att.id_transformation_mapping = map.id_transformation_mapping
          LEFT JOIN dta.attribute                AS col ON col.meta_is_active = 1 AND col.id_attribute              = att.id_attribute
          LEFT JOIN dta.ingestion_etl            AS etl ON etl.meta_is_active = 1 AND etl.id_dataset                = prt.id_dataset
          WHERE prt.id_dataset             = @id_dataset
          AND   PRT.id_model               = @ip_id_model
          AND   PRT.ni_transformation_part = @ni_prt
          AND   prt.meta_is_active = 1;

          /* Build the "Source"-query for the "Transformation"-part. */
          SET @qry += @nwl + '  ' + @tx_sql_select;
          SET @qry += @nwl + '       , meta_dt_valid_from = CONVERT(DATETIME, ' + @tx_sql_for_meta_dt_valid_from + ')';
          SET @qry += @nwl + '       , meta_dt_valid_till = CONVERT(DATETIME, ' + @tx_sql_for_meta_dt_valid_till + ')';
            
          IF (@tx_sql_from     != '') BEGIN SET @qry += @nwl + '  ' + @tx_sql_from;  END;           
          IF (@tx_sql_where    != '') BEGIN SET @qry += @nwl + '  ' + @tx_sql_where; END;
          IF (@tx_sql_group_by != '') BEGIN 
            SET @qry += @nwl + '  ' + @tx_sql_group_by;
            IF (@is_utilized_column_used_in_valid_from = 1 AND @is_aggregate_function_used_valid_from = 0) BEGIN SET @qry += @nwl + '         , CONVERT(DATETIME, ' + @tx_sql_for_meta_dt_valid_from + ')'; END;
            IF (@is_utilized_column_used_in_valid_till = 1 AND @is_aggregate_function_used_valid_till = 0) BEGIN SET @qry += @nwl + '         , CONVERT(DATETIME, ' + @tx_sql_for_meta_dt_valid_till + ')'; END;
          END
          IF (@tx_sql_group_by = '' AND @is_aggregate_function_used = 1) BEGIN
            SET @qry += @nwl + IIF(@is_utilized_column_used_in_valid_from = 1 AND @is_aggregate_function_used_valid_from = 0, '  GROUP BY CONVERT(DATETIME, ' + @tx_sql_for_meta_dt_valid_from + ')', '');
            IF (@is_utilized_column_used_in_valid_till = 1 AND @is_aggregate_function_used_valid_till = 0) BEGIN 
              SET @qry+=@nwl + IIF(@is_utilized_column_used_in_valid_from = 0 OR (@is_utilized_column_used_in_valid_from = 1 AND @is_aggregate_function_used_valid_from = 0), '  GROUP BY ', '         , ') + 'CONVERT(DATETIME, ' + @tx_sql_for_meta_dt_valid_till + ')'; 
            END
          END
          IF (@tx_sql_having != '') BEGIN SET @qry += @nwl + '  ' + @tx_sql_having; END;

          /* Add "UNION ALL" if there is a "Next" "Transformation"-part. */
          IF ((@ni_prt + 1) <= @mx_prt) BEGIN SET @qry += @nwl + 'UNION ALL'; END

        /* Next "Transformation"-part */
        SET @ni_prt += 1; END /* WHILE (@ni_prt < @mx_prt) */

        IF (1=1 /* After all "Transformation"-part(s) sourcequeryies are added. */) BEGIN
          SET @qry += @nwl + ') [main]';
        END

        IF (@ip_is_debugging=1) BEGIN 
          PRINT('/* Build SQL Statement for the "Source" query */');
          EXEC gnc_commen.to_concol_window @qry;
        END

     END

    END
    
    IF (1=1 /* Build INSERT-Statement */) BEGIN
      SET @qry = 'INSERT INTO ' + @tsa + ' (' + REPLACE(@tx_attributes, 's.[', '[') + 'meta_dt_valid_from, meta_dt_valid_till, meta_is_active, meta_ch_rh, meta_ch_bk, meta_ch_pk)' 
               + @nwl + @qry;
      SET @tx_query_source = REPLACE(@qry, '"', '''');
    END

    /* Replace the "double"-qouts for a "double-double"-quots. This is needed, because the @tx_query_source is to be passed into the "return"-resultset as a string. */
    --SET @tx_query_source = REPLACE(@qry, '"', '""');
    IF (@ip_is_debugging = 1) BEGIN PRINT('@tx_query_source : ' + @tx_query_source); END

  END

  IF (1=1 /* Add "SQL" for "Update"-query for "Target processing type is "Fullload". */) BEGIN
    SET @sql  = @emp + 'UPDATE t SET';
    SET @sql += @nwl + '  t.meta_is_active = 0, t.meta_dt_valid_till = ISNULL(s.meta_dt_valid_from, @dt_current_stand),';
    
    /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
    /* Extent building SQL Statement for updating "meta_ch_pk", to handle case where data is updated */
    /* retrospectively, meaning the validity of the data has NOT changed, this can be due to         */
    /* corrections in the data. To handle this, without creating duplicate Primarykeys, the          */
    /* meta_ch_pk must be updated!!                                                                  */
    /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
    SET @sql += @nwl + '  t.meta_ch_pk = CASE WHEN s.meta_ch_pk = t.meta_ch_pk'
    SET @sql += @nwl + '                      THEN CONVERT(CHAR(32), HASHBYTES("MD5", CONCAT(t.meta_ch_pk, t.meta_dt_created)), 2)'
    SET @sql += @nwl + '                      ELSE S.meta_ch_pk'
    SET @sql += @nwl + '                 END'
    /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
    
    SET @sql += @nwl + 'FROM ' + @tgt + ' AS t LEFT JOIN ' + @src + ' AS s ON t.meta_ch_bk = s.meta_ch_bk';
    SET @sql += @nwl + 'WHERE t.meta_is_active = 1 AND t.meta_ch_rh != ISNULL(s.meta_ch_rh,"n/a")';
    SET @sql += @nwl + IIF(@nm_processing_type='Incremental', 'AND t.meta_ch_bk IN (SELECT meta_ch_bk FROM ' + @src + ')',''); 
    SET @tx_query_update = REPLACE(@sql, '"', '''');
  END
  
  IF (1=1 /* Add "SQL" for "Insert"-query for "Target processing type is "Fullload". */) BEGIN
    SET @sql  = @emp + 'INSERT INTO ' + @tgt + ' (' + REPLACE(@tx_attributes, 's.[', '[') + 'meta_dt_valid_from, meta_dt_valid_till, meta_is_active, meta_ch_rh, meta_ch_bk, meta_ch_pk)';
    SET @sql += @nwl + 'SELECT ' + @tx_attributes + ' s.meta_dt_valid_from, s.meta_dt_valid_till, s.meta_is_active, s.meta_ch_rh, s.meta_ch_bk, s.meta_ch_pk';
    SET @sql += @nwl + 'FROM ' + @src + ' AS s LEFT JOIN ' + @tgt + ' AS t ON t.meta_is_active = 1 AND t.meta_ch_rh = s.meta_ch_rh';
    SET @sql += @nwl + 'WHERE t.meta_ch_pk IS NULL'
    SET @tx_query_insert = REPLACE(@sql, '"', '''');
  END

  IF (1 = 1 /* All "Ingestion"-datasets are historized. */) BEGIN
            
    /* Build SQL Statement */
    SET @sql  = @emp + '/* Initialization of the `Run` in the `rdp.run_start`, the  `Previous Stand` is Determined based on meta_dt_valid_from and meta_dt_valid_till, hereby `9999-12-31` and greater are excluded. */'
    SET @sql += @nwl + 'SELECT @dt_previous_stand = SELECT @dt_previous_stand = IIF(@ip_is_override_fullload=0, CONVERT(DATETIME2(7), MAX(run.dt_previous_stand)), CONVERT(DATETIME2(7), "1970-01-01"))'
    SET @sql += @nwl + '     , @dt_current_stand  = CONVERT(DATETIME2(7), MAX(run.dt_current_stand))'
    SET @sql += @nwl + 'FROM rdp.run AS run'
    SET @sql += @nwl + 'WHERE run.id_model   = "' + @ip_id_model + '"'
    SET @sql += @nwl + 'AND   run.id_dataset = "' + @id_dataset + '"'
    SET @sql += @nwl + 'AND   run.dt_run_started = ('
    SET @sql += @nwl + '  /* Find the `Previous` run that NOT ended in `Failed`-status. */'
    SET @sql += @nwl + '  SELECT MAX(dt_run_started)'
    SET @sql += @nwl + '  FROM rdp.run'
    SET @sql += @nwl + '  WHERE id_model             = "' + @ip_id_model + '"'
    SET @sql += @nwl + '  AND   id_dataset           = "' + @id_dataset + '"'
    SET @sql += @nwl + '  AND   id_processing_status = gnc_commen.id_processing_status("<id_model>", "Finished")'
    SET @sql += @nwl + ')'

    /* Set SQL Statement for "Calculation"-dates */
    SET @tx_query_calculation = @sql

  END

  IF (1=1 /* Build SQL Statemen for creation of "Stored Procedure" */) BEGIN

    /* Build SQL Statement for drop of "Stored Procedure" */
    SET @tx_message = '-- Dropping procedure if exists "'+ @ip_nm_target_schema +'"."' + @ip_nm_target_table + '"';
    SET @tx_sql     = 'DROP PROCEDURE IF EXISTS [' + @ip_nm_target_schema +'].[usp_' + @ip_nm_target_table + ']'; 
    EXEC gnc_commen.show_and_execute_sql @tx_message, @tx_sql, @ip_is_debugging, @ip_is_testing;
    PRINT('GO');
    PRINT('');

    /* Build SQL Statement for creation of "Stored Procedure" */
    SET @tx_message = '-- Create procedure for updating "Target"-dataset';
    SET @tx_sql  = @emp + 'CREATE PROCEDURE ' + @ip_nm_target_schema +'.usp_' + @ip_nm_target_table + CASE WHEN (@is_ingestion = 1) THEN ' AS' 
      ELSE /* In case of "Transformation" */
        @nwl + '  /* Input Parameter(s) */' +
        @nwl + '  @ip_ds_external_reference_id NVARCHAR(999) = "n/a",' +
        @nwl + '  @ip_is_override_fullload     BIT = 0' +
        @nwl + '  ' + 
        @nwl + 'AS' 
      END
    SET @tx_sql += @nwl + ''
    SET @tx_sql += @nwl + '/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */'
    SET @tx_sql += @nwl + '/* !!!                                                                            !!! */'
    SET @tx_sql += @nwl + '/* !!! This Stored Procdures has been generated by excuting the procedure of      !!! */'
    SET @tx_sql += @nwl + '/* !!! mdm.create_user_specified_procedure, see example here below.               !!! */'
    SET @tx_sql += @nwl + '/* !!!                                                                            !!! */'
    SET @tx_sql += @nwl + '/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */'
    SET @tx_sql += @nwl + '/* ' 
    SET @tx_sql += @nwl + '-- Example for `Generation of ' + @nm_data_flow_type + ' Procedure`:'
    SET @tx_sql += @nwl + 'EXEC mdm.create_user_specified_procedure'
    SET @tx_sql += @nwl + '  @ip_model            = "' + @ip_id_model         + '", '
    SET @tx_sql += @nwl + '  @ip_nm_target_schema = "' + @ip_nm_target_schema + '", '
    SET @tx_sql += @nwl + '  @ip_nm_target_table  = "' + @ip_nm_target_table  + '", '
    SET @tx_sql += @nwl + '  @ip_is_debugging     = 0, '
    SET @tx_sql += @nwl + '  @ip_is_testing       = 0; '
    SET @tx_sql += @nwl + 'GO'
    SET @tx_sql += @nwl + ''
    SET @tx_sql += @nwl + '-- Example for `Executing the ' + @nm_data_flow_type + ' Procedure`:'
    SET @tx_sql += @nwl + 'EXEC ' + @ip_nm_target_schema +'.usp_' + @ip_nm_target_table +';'
    SET @tx_sql += @nwl + 'GO'
    SET @tx_sql += @nwl + ''
    SET @tx_sql += @nwl + '*/ '
    SET @tx_sql += @nwl + '/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */'
    SET @tx_sql += @nwl + ''
    SET @tx_sql += @nwl + 'DECLARE /* Local Variables */'
    SET @tx_sql += @nwl + '  @id_dataset          CHAR(32)      = "' + @id_dataset + '", ' 
    SET @tx_sql += @nwl + '  @nm_target_schema    NVARCHAR(128) = "' + @ip_nm_target_schema + '", '
    SET @tx_sql += @nwl + '  @nm_target_table     NVARCHAR(128) = "' + @ip_nm_target_table + '", '
    SET @tx_sql += @nwl + '  @tx_error_message    NVARCHAR(MAX),'
    SET @tx_sql += @nwl + '  @dt_previous_stand   DATETIME2(7),'
    SET @tx_sql += @nwl + '  @dt_current_stand    DATETIME2(7),'
    SET @tx_sql += @nwl + '  @id_run              CHAR(32)       = NULL,'
    SET @tx_sql += @nwl + '  @is_transaction      BIT            = 0, -- Helper to keep track if a transaction has been started.'
    SET @tx_sql += @nwl + '  @ni_before           INT            = 0, -- # Record "Before" processing.'
    SET @tx_sql += @nwl + '  @ni_ingested         INT            = 0, -- # Record that were "Ingested".'
    SET @tx_sql += @nwl + '  @ni_inserted         INT            = 0, -- # Record that were "Inserted".'
    SET @tx_sql += @nwl + '  @ni_updated          INT            = 0, -- # Record that were "Updated".'
    SET @tx_sql += @nwl + '  @ni_after            INT            = 0, -- # Record "After" processing.'
    SET @tx_sql += @nwl + '  @cd_procedure_step   NVARCHAR(32),'
    SET @tx_sql += @nwl + '  @ds_procedure_step   NVARCHAR(999);'
    SET @tx_sql += @nwl + '  '
    SET @tx_sql += @nwl + 'BEGIN'
    SET @tx_sql += @nwl + '  ' 
    SET @tx_sql += @nwl + '  /* Turn off Effected Row */' 
    SET @tx_sql += @nwl + '  SET NOCOUNT ON;'
    SET @tx_sql += @nwl + '  ' 
    SET @tx_sql += @nwl + '  /* Turn off Warnings */' 
    SET @tx_sql += @nwl + '  SET ANSI_WARNINGS OFF;'
    SET @tx_sql += @nwl + '  ' 
    IF (@is_ingestion = 1) BEGIN SET @tx_sql += @emp + ''; END; IF (@is_ingestion = 0) BEGIN /* In case of "Transformation" */
    SET @tx_sql += @nwl + '  SET @cd_procedure_step = "STR";'
    SET @tx_sql += @nwl + '  IF (1=1) BEGIN SET @ds_procedure_step = "Start Run (only for `Transformations` needed, with `Ingestions` the `Run` is started via the `orchastration`-tool like `Azure Data Factory` for instance.)";'
    SET @tx_sql += @nwl + '    EXEC rdp.run_start "<id_model>", @id_dataset, @ip_ds_external_reference_id;'
    SET @tx_sql += @nwl + '  END'
    SET @tx_sql += @nwl + '  '; END
    SET @tx_sql += @nwl + '  IF (1=1 /* Extract `Last` calculation datetime. */) BEGIN'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      ' + REPLACE(@tx_query_calculation, @nwl, @tb2)
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '  END' 
    SET @tx_sql += @nwl + '  ' 
    SET @tx_sql += @nwl + '  /* Calculate # Records "before" Processing. */'
    SET @tx_sql += @nwl + '  SELECT @ni_before = COUNT(1) FROM [' + @ip_nm_target_schema + '].[' + @ip_nm_target_table + '] WHERE [meta_is_active] = 1'
    SET @tx_sql += @nwl + '  '
    SET @tx_sql += @nwl + '  SET @cd_procedure_step = "SRC";'
    SET @tx_sql += @nwl + '  IF (1=1) BEGIN SET @ds_procedure_step = "Execute `Source`-query and insert result into `Temporal Staging Area`-table.";'
    SET @tx_sql += @nwl + '    '
    SET @tx_sql += @nwl + '    BEGIN TRY'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      /* `Truncate of the `Temporal (Landing and/or) Staging Area`-table(s). */'
    SET @tx_sql += @nwl + '      TRUNCATE TABLE [tsa_' + @ip_nm_target_schema + '].[tsa_' + @ip_nm_target_table + '];' 
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      /* Start the `Transaction`. */' 
    SET @tx_sql += @nwl + '      BEGIN TRANSACTION; SET @is_transaction = 1;'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      ' + REPLACE(@tx_query_source, @nwl, @tb3)
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      /* Set # Ended records. */'
    SET @tx_sql += @nwl + '      SET @ni_ingested = @@ROWCOUNT;'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      /* Commit the `Transaction`. */'
    SET @tx_sql += @nwl + '      COMMIT TRANSACTION; SET @is_transaction = 0;'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '    END TRY'
    SET @tx_sql += @nwl + '    BEGIN CATCH'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      /* An `Error` occured`, rollback the transaction and register the `Error` in the Logging. */'
    SET @tx_sql += @nwl + '      IF (@@TRANCOUNT > 0) BEGIN ROLLBACK TRANSACTION; EXEC rdp.run_failed "<id_model>", @id_dataset; END;'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      IF (@id_run IS NULL) BEGIN'
    SET @tx_sql += @nwl + '        SET @tx_error_message = "ERROR: Loading of data to `Temporal Staging Area`-table `' + @ip_nm_target_schema + '.' + @ip_nm_target_table + '` failed!"'
    SET @tx_sql += @nwl + '        RAISERROR(@tx_error_message, 18, 1)'
    SET @tx_sql += @nwl + '      END' 
    SET @tx_sql += @nwl + '    END CATCH  '
    SET @tx_sql += @nwl + '  END'
    SET @tx_sql += @nwl + '  ' 
    SET @tx_sql += @nwl + '  BEGIN TRY'
    SET @tx_sql += @nwl + '    ' 
    SET @tx_sql += @nwl + '    SET @cd_procedure_step = "RUN";'
    SET @tx_sql += @nwl + '    IF (1=1) BEGIN SET @ds_procedure_step = "Check that there is an `Run-Dataset`-process running.";'
    SET @tx_sql += @nwl + '      '  
    SET @tx_sql += @nwl + '      /* Fetch the Latest `Run ID`. */' 
    SET @tx_sql += @nwl + '      SET @id_run = rdp.get_id_run("<id_model>", @id_dataset);' 
    SET @tx_sql += @nwl + '      '  
    SET @tx_sql += @nwl + '      /* Raise Error to indicate that the process of `Adding` and `Ending` of records was not logged as started! */'
    SET @tx_sql += @nwl + '      IF (@id_run IS NULL) BEGIN'
    SET @tx_sql += @nwl + '        SET @tx_error_message = "ERROR: NO running `process` for dataset `' + @ip_nm_target_schema + '.' + @ip_nm_target_table + '`!"'
    SET @tx_sql += @nwl + '        RAISERROR(@tx_error_message, 18, 1)'
    SET @tx_sql += @nwl + '      END' 
    SET @tx_sql += @nwl + '      '  
    SET @tx_sql += @nwl + '    END' 
    SET @tx_sql += @nwl + '    '
    SET @tx_sql += @nwl + '    /* Start the `Transaction`. */' 
    SET @tx_sql += @nwl + '    BEGIN TRANSACTION; SET @is_transaction = 1;'
    SET @tx_sql += @nwl + '    '
    SET @tx_sql += @nwl + '    SET @cd_procedure_step = "END";'
    SET @tx_sql += @nwl + '    IF (1=1) BEGIN SET @ds_procedure_step = "`End` records that are nolonger in `Source` and still in `Target`.;"'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      ' + REPLACE(@tx_query_update, @nwl, @tb3)
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      /* Set # Ended records. */'
    SET @tx_sql += @nwl + '      SET @ni_updated = @@ROWCOUNT;'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '    END'
    SET @tx_sql += @nwl + '    '
    SET @tx_sql += @nwl + '    SET @cd_procedure_step = "ADD";'
    SET @tx_sql += @nwl + '    IF (1=1) BEGIN SET @ds_procedure_step = "`Add` records that are in the `Source` and NOT in `Target`.";'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      ' + REPLACE(@tx_query_insert, @nwl, @tb3)
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      /* Set # Added records. */'
    SET @tx_sql += @nwl + '      SET @ni_inserted = @@ROWCOUNT;'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '    END'
    SET @tx_sql += @nwl + '    '
    SET @tx_sql += @nwl + '    /* Calculate # Records `After` Processing. */'
    SET @tx_sql += @nwl + '    SELECT @ni_after = COUNT(1) FROM [' + @ip_nm_target_schema + '].[' + @ip_nm_target_table + '] WHERE [meta_is_active] = 1'
    SET @tx_sql += @nwl + '    '
    SET @tx_sql += @nwl + '    IF (1=1 /* Validate uniqueness of meta_ch_pk, if NOT Unique then Raise ERROR and rollback !!! */) BEGIN'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      /* Local Variable for Executing Check(s) */'
    SET @tx_sql += @nwl + '      DECLARE @ni_expected INT, @ni_measured INT;'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      SET @cd_procedure_step = "CPK";'
    SET @tx_sql += @nwl + '      IF (1=1) BEGIN SET @ds_procedure_step = "Execute Check if `meta_ch_pk`-attribute values are unique.";'
    SET @tx_sql += @nwl + '        SELECT @ni_expected = COUNT(1), @ni_measured = COUNT(DISTINCT meta_ch_pk) FROM ' + @ip_nm_target_schema + '.' + @ip_nm_target_table
    SET @tx_sql += @nwl + '        IF (@ni_expected != @ni_measured) BEGIN'
    SET @tx_sql += @nwl + '            SET @tx_error_message  = "ERROR: meta_ch_pk NOT unique for ' + @ip_nm_target_schema + '.' + @ip_nm_target_table + '!" + CHAR(10) + "-- SQL Statement:"'
    SET @tx_sql += @nwl + '            SET @tx_error_message += CHAR(10) + "SELECT * FROM ' + @tsa + '"'
    SET @tx_sql += @nwl + '            SET @tx_error_message += CHAR(10) + "WHERE meta_ch_pk IN (SELECT meta_ch_pk FROM ' + @tsa + ' GROUP BY meta_ch_pk HAVING COUNT(*) > 1);"'
    SET @tx_sql += @nwl + '            RAISERROR(@tx_error_message, 18, 1)'
    SET @tx_sql += @nwl + '        END'
    SET @tx_sql += @nwl + '      END'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '      SET @cd_procedure_step = "APK";'
    SET @tx_sql += @nwl + '      IF (1=1) BEGIN SET @ds_procedure_step = "Accuracy only 1 `Active` record per `Primarykey`.";'
    SET @tx_sql += @nwl + '        SELECT @ni_expected = COUNT(         CONCAT("|"' + @tx_pk_fields + '))'
    SET @tx_sql += @nwl + '             , @ni_measured = COUNT(DISTINCT CONCAT("|"' + @tx_pk_fields + '))'
    SET @tx_sql += @nwl + '        FROM ' + @ip_nm_target_schema + '.' + @ip_nm_target_table + ' AS s'
    SET @tx_sql += @nwl + '        WHERE s.meta_is_active = 1' 
    SET @tx_sql += @nwl + '        IF (@ni_expected != @ni_measured) BEGIN'
    SET @tx_sql += @nwl + '            SET @tx_error_message  = "ERROR: There should only be 1 record per `Primarykey(s)` for ' + @ip_nm_target_schema + '.' + @ip_nm_target_table + '!"'
    SET @tx_sql += @nwl + '            RAISERROR(@tx_error_message, 18, 1)'
    SET @tx_sql += @nwl + '        END'
    SET @tx_sql += @nwl + '      END'
    SET @tx_sql += @nwl + '      '
    SET @tx_sql += @nwl + '    END'
    SET @tx_sql += @nwl + '    '
    SET @tx_sql += @nwl + '    /* Commit the `Transaction`. */'
    SET @tx_sql += @nwl + '    COMMIT TRANSACTION; SET @is_transaction = 0;'
    SET @tx_sql += @nwl + '    '
    SET @tx_sql += @nwl + '    /* Cleanup of the `Temporal (Landing and/or) Staging Area`-table(s). */'
    SET @tx_sql += @nwl + '    TRUNCATE TABLE [tsa_' + @ip_nm_target_schema + '].[tsa_' + @ip_nm_target_table + '];' 
    SET @tx_sql += @nwl + '    '
    SET @tx_sql += @nwl + '    /* Set Run Dataset to Success */'
    SET @tx_sql += @nwl + '    EXEC rdp.run_finish "<id_model>", @id_dataset, @ni_before, @ni_ingested, @ni_inserted, @ni_updated, @ni_after'
    SET @tx_sql += @nwl + '    '
    SET @tx_sql += @nwl + '    /* All done */'
    SET @tx_sql += @nwl + '    PRINT("Data Ingestion for Dataset `' + @ip_nm_target_schema + '`.`' + @ip_nm_target_table + '` has been successfull.")'
    SET @tx_sql += @nwl + '    '
    SET @tx_sql += @nwl + '  END TRY'
    SET @tx_sql += @nwl + '  '
    SET @tx_sql += @nwl + '  BEGIN CATCH'
    SET @tx_sql += @nwl + '    '
    SET @tx_sql += @nwl + '    /* An `Error` occured`, rollback the transaction and register the `Error` in the Logging. */'
    SET @tx_sql += @nwl + '    IF (@@TRANCOUNT > 0) BEGIN ROLLBACK TRANSACTION; EXEC rdp.run_failed "<id_model>", @id_dataset; END;'
    SET @tx_sql += @nwl + '    '
    SET @tx_sql += @nwl + '    /* Ended in `Error` ! */'
    SET @tx_sql += @nwl + '    PRINT("Data `' + CASE WHEN @is_ingestion = 1 THEN 'Ingestion' ELSE 'Transformation' END + '` for Dataset `' + @ip_nm_target_schema + '`.`' + @ip_nm_target_table + '` has ended in `Error`.")'
    SET @tx_sql += @nwl + '    PRINT(ISNULL(@tx_error_message, "ERROR (" + @cd_procedure_step + ") : " + @ds_procedure_step))'
    SET @tx_sql += @nwl + '    '
    SET @tx_sql += @nwl + '  END CATCH'
    SET @tx_sql += @nwl + '  '
    SET @tx_sql += @nwl + '  /* Update "Documentation" */'
    SET @tx_sql += @nwl + '  EXEC mdm.usp_build_html_file_dataset @ip_id_model = "<id_model>", @ip_id_dataset = @id_dataset;'
    SET @tx_sql += @nwl + '  '
    SET @tx_sql += @nwl + 'END'
    SET @tx_sql = REPLACE(@tx_sql, '<id_model>', @ip_id_model);
    SET @tx_sql = REPLACE(@tx_sql, '"', '''');
    EXEC gnc_commen.show_and_execute_sql @tx_message, @tx_sql, @ip_is_debugging, @ip_is_testing;
    PRINT('GO');
    PRINT('');

  END  

END
GO