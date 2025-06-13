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
  @nm_ingestion         NVARCHAR(128),
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
  @ptp NVARCHAR(MAX) = '',
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
  @id_transformation_part       CHAR(32),
  @ni_transformation_part       INT,
  @tx_transformation_part       NVARCHAR(MAX),
  @cd_union_type                NVARCHAR(32),
  @tx_sql_attribute             NVARCHAR(MAX),
  @tx_sql_where_and_or_group_by NVARCHAR(MAX),
  @is_group_by_used             BIT,
  @is_aggregate_function_used   BIT,
        
  /* "Transformation"-datasets */
  @id_transformation_dataset       CHAR(32),
  @tx_sql_for_replace_from_dataset NVARCHAR(MAX),
  @cd_alias_for_from               NVARCHAR(MAX),
  @cd_alias_for_full_join          NVARCHAR(MAX),

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
           @ptp = CASE WHEN dst.is_ingestion = 1 THEN etl.nm_processing_type ELSE 'Incremental' END,
           @is_ingestion = dst.is_ingestion,
           @nm_ingestion = CASE WHEN dst.is_ingestion = 1 THEN 'Ingestion' ELSE 'Transformation' END,
           @tx_query_source = REPLACE(dst.tx_source_query, '<newline>', @nwl),
           @nm_processing_type            = IIF(dst.nm_target_schema = 'dq_totals', 'Fullload', IIF(ISNULL(dst.is_ingestion, 0)=1, etl.nm_processing_type, 'Incremental')),
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

    PRINT('@is_ingestion : ' + CONVERT(NVARCHAR(1), @is_ingestion));
    IF (@is_ingestion = 1 /* Extent the "Source"-query */) BEGIN

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
      PRINT('processed as ingestion');

    END
    IF (@is_ingestion = 0 /* Extent the "Transformation"-query */) BEGIN 
      
      IF (@ip_is_debugging=1) BEGIN PRINT('/* Extent the "Transformation"-query */'); END

      IF (1=1 /* Determine if "FULL JOIN" or "UNION" is "used" for the "Transformations". */) BEGIN

        SELECT @is_full_join_used = CASE WHEN (COUNT(*)>0) THEN 1 ELSE 0 END
        FROM dta.transformation_dataset 
        WHERE meta_is_active          = 1 
        AND   id_model                = @ip_id_model
        AND   cd_join_type            = 'FULL JOIN'
        AND   id_transformation_part IN (
          SELECT id_transformation_part 
          FROM dta.transformation_part 
          WHERE meta_is_active = 1 
          AND id_dataset       = @id_dataset 
          AND id_model         = @ip_id_model
        );

        SELECT @is_union_join_used = CASE WHEN (COUNT(*)>1) THEN 1 ELSE 0 END
        FROM dta.transformation_part
        WHERE meta_is_active   = 1
        AND   id_model         = @ip_id_model
        AND   id_dataset       = @id_dataset;
        
        SET @tx_sql_main_where_statement = CASE 
          WHEN @is_full_join_used = 1 OR @is_union_join_used = 1 
          THEN 'WHERE ([main].[meta_dt_valid_from] ' + @tx_sql_between + ') OR ([main].[meta_dt_valid_till] ' + @tx_sql_between + ')'
          ELSE ''
        END;

      END        
      IF (1=1 /* Extract "Parts" for the "Transformations". */) BEGIN

        DROP TABLE IF EXISTS #transformation_part; SELECT 
          id_transformation_part,
          ni_transformation_part,
          CASE /*  AS cd_union_type */

            WHEN ni_transformation_part > 1 
            AND  UPPER(@tx_query_source) LIKE '%UNION%ALL%' 
            THEN 'UNION ALL '
            
            WHEN ni_transformation_part > 1 
            AND  UPPER(@tx_query_source) LIKE '%UNION%' 
            THEN 'UNION '

            ELSE ''

          END AS cd_union_type,
          TRIM(SUBSTRING(tx_transformation_part, 1, CHARINDEX('FROM', tx_transformation_part, 1) - 1)) AS tx_sql_attribute,
          CASE /* AS tx_sql_where_and_or_group_by */
            
            WHEN CHARINDEX('WHERE', tx_transformation_part, 1) != 0 
            THEN SUBSTRING(tx_transformation_part, CHARINDEX('WHERE', tx_transformation_part, 1), LEN(tx_transformation_part))
            
            WHEN CHARINDEX('GROUP BY', tx_transformation_part, 1) != 0 
            THEN SUBSTRING(tx_transformation_part, CHARINDEX('GROUP BY', tx_transformation_part, 1), LEN(tx_transformation_part))
            
            ELSE ''

          END AS tx_sql_where_and_or_group_by
        INTO #transformation_part
        FROM dta.transformation_part
        WHERE meta_is_active = 1 
        AND   id_model       = @ip_id_model
        AND   id_dataset     = @id_dataset
        ORDER By ni_transformation_part;

        /* If IN DEBUG mode, show the "Transformation"-parts. */
        IF (@ip_is_debugging=1) BEGIN SELECT * FROM #transformation_part; END;

      END
      IF (1=1 /* Extract "Datasets" for the "Transformations". */) BEGIN
        DROP TABLE IF EXISTS #transformation_dataset; SELECT 
          tds.id_transformation_part,
          tds.id_transformation_dataset,
          tds.ni_transformation_dataset,
          tds.cd_alias, 
		      tds.cd_join_type,
          CASE /* If the "Dataset" is DQ related and specificly the "Totals", which is "Generated", this is always "Fullload". */
		        WHEN tds.cd_join_type                    = 'FROM'
		        AND  @ip_nm_target_schema                = 'dq_totals'
		        AND  SUBSTRING(@ip_nm_target_table, 1,3) = 'dqt'
			      THEN '  ' + tds.cd_join_type+' ['+dst.nm_target_schema+'].['+dst.nm_target_table+'] AS [' + tds.cd_alias + ']' 
               + IIF(LEN(ISNULL(tds.tx_join_criteria,'-')) > 1, ' ON ' + REPLACE(ISNULL(tds.tx_join_criteria, ' '), '''', '"'), '')
		       
			   /* Other "Datasets". */ 
			   WHEN tds.cd_join_type    = 'FROM' 
			   AND  @is_full_join_used  = 0 
               THEN  '  FROM (' /* Convert "FROM@is_union_join_used"-dataset into "subquery" that is filter on BK that have "change" that will "poisiblily" effect the result of the "Transformation". */
               +@nwl+'    SELECT * FROM ['+dst.nm_target_schema+'].['+dst.nm_target_table+'] AS ['+tds.cd_alias+'] WHERE ['+tds.cd_alias+'].[meta_ch_bk] IN (' 
               +@nwl+'      SELECT [meta_ch_bk] FROM ['+dst.nm_target_schema+'].['+dst.nm_target_table+']'
               +@nwl+'      WHERE ([meta_dt_valid_from] '+@tx_sql_between+')'
               +@nwl+'         OR ([meta_dt_valid_till] '+@tx_sql_between+')'
               +@nwl+'    )'
               +@nwl+'  ) AS ['+tds.cd_alias+']'

				/* If NOT From */
				ELSE '  ' + tds.cd_join_type+' ['+dst.nm_target_schema+'].['+dst.nm_target_table+'] AS [' + tds.cd_alias + ']' + IIF(LEN(ISNULL(tds.tx_join_criteria,'-')) > 1, ' ON ' + REPLACE(ISNULL(tds.tx_join_criteria, ' '), '''', '"'), '')

          END AS tx_sql_for_replace_from_dataset
        INTO #transformation_dataset 
        FROM dta.transformation_dataset AS tds JOIN dta.dataset AS dst 
        ON  dst.id_dataset     = tds.id_dataset 
        AND dst.id_model       = tds.id_model
        AND dst.meta_is_active = 1 
        WHERE tds.meta_is_active          = 1 
        AND   tds.id_model                = @ip_id_model
        AND   tds.id_transformation_part IN (SELECT id_transformation_part FROM #transformation_part);

        /* If IN DEBUG mode, show the "Transformation"-datasets. */
        IF (@ip_is_debugging=1) BEGIN SELECT * FROM #transformation_dataset; END;

      END
        
      /* Build SQL Statement for "main" */
      SET @qry  = @emp + 'SELECT';
      SET @qry += @nwl + '  ' + REPLACE(@att, @nwl, @tb1);
      SET @qry += @emp +   '[main].[meta_dt_valid_from] AS [meta_dt_valid_from],';
      SET @qry += @nwl + '  [main].[meta_dt_valid_till] AS [meta_dt_valid_till],';
      SET @qry += @nwl + '  CONVERT(BIT, IIF([main].[meta_dt_valid_till] >= CONVERT(DATETIME, "9999-12-31"),1,0)) AS [meta_is_active],';
      SET @qry += @nwl + '  CONVERT(CHAR(32), HASHBYTES("MD5", ' + @rwh + ', 2) AS [meta_ch_rh],';
      SET @qry += @nwl + '  CONVERT(CHAR(32), HASHBYTES("MD5", ' + @bks + ', 2) AS [meta_ch_bk],';
      SET @qry += @nwl + '  CONVERT(CHAR(32), HASHBYTES("MD5", ' + @pks + ', 2) AS [meta_ch_pk]';
      SET @qry += @nwl + 'FROM (';
            
      WHILE ((SELECT COUNT(*) FROM #transformation_part)>0) BEGIN
        
        SELECT /* Fetch next Values */
            @id_transformation_part       = nxt.id_transformation_part,
            @cd_union_type                = nxt.cd_union_type,
            @tx_sql_attribute             = REPLACE(nxt.tx_sql_attribute, '''', '"'),
            @tx_sql_where_and_or_group_by = nxt.tx_sql_where_and_or_group_by
        FROM (SELECT TOP 1 * FROM #transformation_part ORDER BY ni_transformation_part ASC) AS nxt;
        DELETE FROM #transformation_part WHERE id_transformation_part = @id_transformation_part;
        IF (@ip_is_debugging=1) BEGIN PRINT(CONCAT(' @id_transformation_part : ', @id_transformation_part)); END;

        IF (1=1 /* Determine group by usage */ ) BEGIN

          SET @is_group_by_used = CASE 
              WHEN CHARINDEX('GROUP~BY', UPPER(REPLACE(@tx_sql_where_and_or_group_by, ' ', '~')), 1) > 0 THEN 1 
              ELSE 0
          END;

          SET @is_aggregate_function_used = CASE

              /* Common SQL Aggregate Functions */
              WHEN CHARINDEX('COUNT(', UPPER(REPLACE(@tx_sql_attribute, ' ', '')), 1) > 0 THEN 1
              WHEN CHARINDEX('SUM(',   UPPER(REPLACE(@tx_sql_attribute, ' ', '')), 1) > 0 THEN 1 
              WHEN CHARINDEX('AVG(',   UPPER(REPLACE(@tx_sql_attribute, ' ', '')), 1) > 0 THEN 1 
              WHEN CHARINDEX('MAX(',   UPPER(REPLACE(@tx_sql_attribute, ' ', '')), 1) > 0 THEN 1 
              WHEN CHARINDEX('MIN(',   UPPER(REPLACE(@tx_sql_attribute, ' ', '')), 1) > 0 THEN 1 

              /* Other Useful Aggregate Functions (SQL Server-specific and others) */
              WHEN CHARINDEX('STDEV(',        UPPER(REPLACE(@tx_sql_attribute, ' ', '')), 1) > 0 THEN 1
              WHEN CHARINDEX('STDEVP(',       UPPER(REPLACE(@tx_sql_attribute, ' ', '')), 1) > 0 THEN 1
              WHEN CHARINDEX('VAR(',          UPPER(REPLACE(@tx_sql_attribute, ' ', '')), 1) > 0 THEN 1 
              WHEN CHARINDEX('VARP(',         UPPER(REPLACE(@tx_sql_attribute, ' ', '')), 1) > 0 THEN 1
              WHEN CHARINDEX('GROUPING(',     UPPER(REPLACE(@tx_sql_attribute, ' ', '')), 1) > 0 THEN 1
              WHEN CHARINDEX('CHECKSUM_AGG(', UPPER(REPLACE(@tx_sql_attribute, ' ', '')), 1) > 0 THEN 1
              WHEN CHARINDEX('STRING_AGG(',   UPPER(REPLACE(@tx_sql_attribute, ' ', '')), 1) > 0 THEN 1
              WHEN CHARINDEX('JSON_AGG(',     UPPER(REPLACE(@tx_sql_attribute, ' ', '')), 1) > 0 THEN 1

              ELSE 0 
          END;
    
        END;

        /* Build SQL Statement of "Part" for "Attributes" / "Mappings". */
        SET @qry += @tb1 + @cd_union_type + REPLACE(@tx_sql_attribute, @nwl, @tb1) + ',';

        /* Build SQL Statement of "Part" for "meta_dt_valid_from". */       
        SELECT @cd_alias_for_from      = '['+cd_alias+'].[meta_dt_valid_from]' FROM #transformation_dataset WHERE id_transformation_part = @id_transformation_part AND cd_join_type = 'FROM';
        SELECT @cd_alias_for_full_join = '['+cd_alias+'].[meta_dt_valid_from]' FROM #transformation_dataset WHERE id_transformation_part = @id_transformation_part AND cd_join_type = 'FULL JOIN';
        SET @qry += @nwl + '         ';
        IF (@is_full_join_used = 0) BEGIN SET @qry += ''       +@cd_alias_for_from; END;
        IF (@is_full_join_used = 1) BEGIN SET @qry += 'ISNULL('+@cd_alias_for_from+', '+@cd_alias_for_full_join+')'; END;
        SET @qry += ' AS [meta_dt_valid_from],';

        /* Build SQL Statement of "Part" for "meta_dt_valid_till", by replaceing `from` with `till`. */
        SET @cd_alias_for_from      = REPLACE(@cd_alias_for_from     , 'from', 'till');
        SET @cd_alias_for_full_join = REPLACE(@cd_alias_for_full_join, 'from', 'till');
        SET @qry += @nwl + '         ';
        IF (@is_full_join_used = 0) BEGIN SET @qry += ''       +@cd_alias_for_from; END;
        IF (@is_full_join_used = 1) BEGIN SET @qry += 'ISNULL('+@cd_alias_for_from+', '+@cd_alias_for_full_join+')'; END;
        SET @qry += ' AS [meta_dt_valid_till]';
        
        WHILE ((SELECT COUNT(*) FROM #transformation_dataset WHERE id_transformation_part = @id_transformation_part)>0) BEGIN

          SELECT /* Fetch next Values */
            @id_transformation_dataset       = nxt.id_transformation_dataset,
            @tx_sql_for_replace_from_dataset = nxt.tx_sql_for_replace_from_dataset
          FROM (SELECT TOP 1 * 
                FROM #transformation_dataset 
                WHERE id_transformation_part = @id_transformation_part 
                ORDER BY ni_transformation_dataset ASC
          ) AS nxt;
          DELETE FROM #transformation_dataset WHERE id_transformation_dataset = @id_transformation_dataset;

          /* If IN DEBUG mode, show the "Transformation"-datasets. */
          IF (@ip_is_debugging=1) BEGIN 
            PRINT(CONCAT(' @id_transformation_dataset : ', @id_transformation_dataset)); 
          END;

          /* Build SQL Statement of "Part" for "FROM/JON"-clause. */
          SET @qry += @nwl + @tx_sql_for_replace_from_dataset;

        END /* WHILE ((SELECT COUNT(*) FROM #transformation_dataset WHERE @id_transformation_part = @id_transformation_part)>0) */

        /* Build SQL Statement of "Part" for "WHERE/GROUP BY"-clause. */
        SET @qry += @tb1 + REPLACE(@tx_sql_where_and_or_group_by, @nwl, @tb1);

        IF (@is_group_by_used = 1 OR @is_aggregate_function_used = 1 /* If GROUP By is Used of Aggregate Functions were used, extent the query from the Transformation part with (GROUP BY) meta_dt_valid_from/till. */) BEGIN
        /* Build SQL Statement of "Part" for "meta_dt_valid_from". */

          /* GROUP BY is already used. */
          SET @qry += @tb1 + CASE WHEN @is_group_by_used = 1 THEN '       , ' ELSE 'GROUP BY ' END;

          /* Build SQL Statement of "Part" for GROUP BY with "meta_dt_valid_from". */ 
          SET @cd_alias_for_from      = REPLACE(@cd_alias_for_from     , 'till', 'from');
          SET @cd_alias_for_full_join = REPLACE(@cd_alias_for_full_join, 'till', 'from');
          IF (@is_full_join_used = 0) BEGIN SET @qry += ''       +@cd_alias_for_from; END;
          IF (@is_full_join_used = 1) BEGIN SET @qry += 'ISNULL('+@cd_alias_for_from+', '+@cd_alias_for_full_join+')'; END;

          /* Build SQL Statement of "Part" for GROUP BY with "meta_dt_valid_till", by replaceing `from` with `till`. */
          SET @cd_alias_for_from      = REPLACE(@cd_alias_for_from     , 'from', 'till');
          SET @cd_alias_for_full_join = REPLACE(@cd_alias_for_full_join, 'from', 'till');
          IF (@is_full_join_used = 0) BEGIN SET @qry += @tb1 + '       , '       +@cd_alias_for_from; END;
          IF (@is_full_join_used = 1) BEGIN SET @qry += @tb1 + '       , ISNULL('+@cd_alias_for_from+', '+@cd_alias_for_full_join+')'; END;
      
        END;

      END /* WHILE ((SELECT COUNT(*) FROM #transformation_part)>0) */

      /* finish up the "main"-subquery part. */
      SET @qry += @nwl + ') AS [main]';

      IF (@is_full_join_used = 1 /* OR @is_union_join_used = 1*/ /* then the "FROM"-dataset can NOT be filter on BK`s, thus the whole "main"-resultset must be filter afterwards. */) BEGIN
        SET @qry += IIF(LEN(@tx_sql_main_where_statement)!=0, @nwl + @tx_sql_main_where_statement, @emp);
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
    SET @sql += @nwl + IIF(@ptp='Incremental', 'AND t.meta_ch_bk IN (SELECT meta_ch_bk FROM ' + @src + ')',''); 
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
    SET @sql  = @emp + '/* The `Target`-dataset(s) ARE historized. */'
    SET @sql += @nwl + 'SELECT @dt_previous_stand = CONVERT(DATETIME2(7), MAX(run.dt_previous_stand))'
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
        @nwl + '  @ip_ds_external_reference_id NVARCHAR(999) = "n/a"' +
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
    SET @tx_sql += @nwl + '-- Example for `Generation of ' + @nm_ingestion + ' Procedure`:'
    SET @tx_sql += @nwl + 'EXEC mdm.create_user_specified_procedure'
    SET @tx_sql += @nwl + '  @ip_model            = "' + @ip_id_model         + '", '
    SET @tx_sql += @nwl + '  @ip_nm_target_schema = "' + @ip_nm_target_schema + '", '
    SET @tx_sql += @nwl + '  @ip_nm_target_table  = "' + @ip_nm_target_table  + '", '
    SET @tx_sql += @nwl + '  @ip_is_debugging     = 0, '
    SET @tx_sql += @nwl + '  @ip_is_testing       = 0; '
    SET @tx_sql += @nwl + 'GO'
    SET @tx_sql += @nwl + ''
    SET @tx_sql += @nwl + '-- Example for `Executing the ' + @nm_ingestion + ' Procedure`:'
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
    SET @tx_sql += @nwl + '            SET @tx_error_message = "ERROR: meta_ch_pk NOT unique for ' + @ip_nm_target_schema + '.' + @ip_nm_target_table + '!"'
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
    SET @tx_sql += @nwl + '            SET @tx_error_message = "ERROR: There should only be 1 record per `Primarykey(s)` for ' + @ip_nm_target_schema + '.' + @ip_nm_target_table + '!"'
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