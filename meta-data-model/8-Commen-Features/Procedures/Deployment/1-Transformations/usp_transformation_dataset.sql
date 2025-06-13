CREATE PROCEDURE deployment.usp_transformation_dataset
    
    /* Input Parameters */
    @ip_id_transformation_part CHAR(32),
    @ip_tx_transformation_part NVARCHAR(MAX),

    /* Input Parameters */
    @ip_is_debugging BIT = 0,
    @ip_is_testing   BIT = 0

AS DECLARE /* Local Variables */

  /* Current Model */
  @id_model CHAR(32) = (SELECT id_model FROM mdm.current_model),

  /* Temporary Variables */
  @tx_sql_statement   NVARCHAR(MAX),
  @ni_position_begin  INT = 0,
  @ni_position_end    INT = 0,
  @ni_position_length INT = 0,

  /* Temporary vARiables for "Error handling" */
  @tx_error_message NVARCHAR(4000) = '',
  @tx_sql_execution NVARCHAR(MAX)  = '';

BEGIN 
  SET NOCOUNT ON;
  BEGIN TRY
  
    IF (1=1 /* Extraction of "FROM/JOIN"-clauses of "Transformation"-part. */) BEGIN
      
      /* Minify "Query" and "escape"  the "<newline>". */
      SET @tx_sql_statement = gnc_commen.svf_minify(replace(@ip_tx_transformation_part, '<newline>', CHAR(10)));

      /* Find " Beginning" of the "FROM/JOIN"-clause. */ 
      SET @ni_position_begin = CHARINDEX('FROM', UPPER(@tx_sql_statement), 1);

      /* Find the "End" of the "FROM/JOIN"-clause. */ 
      SET @ni_position_end = CHARINDEX('WHERE', UPPER(@tx_sql_statement), 1);
      
      /* If NO "WHERE"-clause found "search for "GROUP BY"-clause. */
      SET @ni_position_end = IIF(@ni_position_end = 0, CHARINDEX('GROUP BY', @tx_sql_statement, 1), @ni_position_end);

      /* If both the "Begin" and "End" have been found, determine the "Length". */
      SET @ni_position_length = IIF(@ni_position_end = 0, LEN(@tx_sql_statement), @ni_position_end - @ni_position_begin);

      /* Extract only the "FROM/JOIN"-clause of the "Query". */
      SET @tx_sql_statement = TRIM(SUBSTRING(@tx_sql_statement, @ni_position_begin, @ni_position_length));

      /* Show extracted "FROM/JOIN"-clause. */
      IF (@ip_is_debugging = 1 ) BEGIN EXEC gnc_commen.to_concol_window @tx_sql_statement; END

    END;

    IF (1=1 /* "Temp"-table: tx -> Convert "SQL"-statement to individual "words". */) BEGIN
      DROP TABLE IF EXISTS #tx; SELECT 
        @id_model   AS id_model,
        TRIM(VALUE) AS tx_sql, 
        1           AS ni_dummy 
      INTO #tx FROM STRING_SPLIT(@tx_sql_statement, ' ');
      IF (@ip_is_debugging = 1) BEGIN SELECT * FROM #tx; END
    END

    IF (1=1 /* "Temp"-table: md -> Match dataset(s) with "parts" of the "SQL"-statement and determine is alias is used. */) BEGIN
      DROP TABLE IF EXISTS #md; SELECT 
        tx.ni_ordering,
        dst.id_model AS id_source_model,
        dst.id_dataset, 
        tx.tx_sql As tx_sql, 
        dst.nm_target_schema, 
        dst.nm_target_table,
        CASE /* AS is_next_word_alias_keyword */
            WHEN tx_sql_next = 'AS' 
            AND  dst.id_dataset IS NOT NULL
            THEN 1 
            ELSE 0 
        END AS is_next_word_alias_keyword,
        CASE /* AS is_prev_word_from_or_join_keyword */
            WHEN tx_sql_next IN ('FROM', 'JOIN') 
            AND  dst.id_dataset IS NOT NULL
            THEN 1 
            ELSE 0 
        END AS is_prev_word_from_or_join_keyword,
        CASE /*  AS is_keyword */
            WHEN UPPER(tx.tx_sql) IN ('INNER', 'CROSS', 'LEFT', 'RIGHT', 'FULL', 'JOIN', 'ON', 'FROM', 'WHERE', 'WHEN')
            THEN 1
            ELSE 0
        END AS is_keyword
        
      INTO #md FROM (
        SELECT ROW_NUMBER()    OVER (PARTITION BY tx.ni_dummy ORDER BY tx.ni_dummy) AS ni_ordering
             , LEAD(tx.tx_sql) OVER (PARTITION BY tx.ni_dummy ORDER BY tx.ni_dummy) AS tx_sql_next
             , tx.* 
        FROM #tx AS tx
      ) AS tx
        
      LEFT JOIN dta.dataset AS dst 
      ON  dst.id_model       = tx.id_model
      AND dst.meta_is_active = 1 
      AND CASE
        WHEN '[' + dst.nm_target_schema + '].'  + dst.nm_target_table +  '' = tx.tx_sql THEN 1
        WHEN ''  + dst.nm_target_schema +  '.[' + dst.nm_target_table + ']' = tx.tx_sql THEN 1
        WHEN '[' + dst.nm_target_schema + '].[' + dst.nm_target_table + ']' = tx.tx_sql THEN 1
        WHEN ''  + dst.nm_target_schema +  '.'  + dst.nm_target_table +  '' = tx.tx_sql THEN 1
        ELSE 0
      END = 1;
      IF (@ip_is_debugging = 1) BEGIN SELECT * FROM #md ORDER BY ni_ordering; END
    END

    IF (1=1 /* "Temp"-table: ni -> determine "from/join"-type and "dataset" and its "alias". */) BEGIN
      DROP TABLE IF EXISTS #ni; SELECT 
        md.tx_sql           AS tx_sql,
        md.ni_ordering      AS ni_ordering,
        CASE /*             AS cd_join_type */
            WHEN ISNULL(jtp.tx_sql, 'n/a') IN ('INNER', 'CROSS', 'LEFT', 'RIGHT', 'FULL')
            THEN jtp.tx_sql + ' ' 
            ELSE ''
        END + foj.tx_sql    AS cd_join_type,
        md.id_dataset       AS id_dataset,
        md.id_source_model  AS id_source_model,
        md.nm_target_schema AS nm_target_schema,
        md.nm_target_table  AS nm_target_table,
        REPLACE(REPLACE( -- AS cd_alias,
          als.tx_sql, 
          '[', ''),
          ']', '') AS cd_alias,
        CASE /*             AS tx_join_criteria */
            WHEN md.is_prev_word_from_or_join_keyword = 1 AND foj.tx_sql  = 'FROM' THEN NULL 
            WHEN md.is_prev_word_from_or_join_keyword = 1 AND foj.tx_sql != 'FROM' THEN 'JOIN-CRIETERIA'
            ELSE NULL 
        END AS tx_join_criteria
        
      INTO #ni
      
      FROM #md AS md 
      
      /* Alias */
      LEFT JOIN #md AS als ON als.ni_ordering = CASE
        WHEN md.nm_target_schema IS NULL THEN -1
        WHEN md.is_next_word_alias_keyword = 1 
        THEN md.ni_ordering + 2
        ELSE md.ni_ordering + 1
      END
      
      /* FROM or JOIN */
      LEFT JOIN #md AS foj ON foj.ni_ordering = CASE
        WHEN md.nm_target_schema IS NULL THEN -1
        WHEN md.is_prev_word_from_or_join_keyword = 1 
        THEN md.ni_ordering - 1
        ELSE -1
        END
        
        /* INNER, CROSS, LEFT, RIGHT or FULL */
        LEFT JOIN #md AS jtp ON jtp.ni_ordering = CASE
        WHEN md.nm_target_schema IS NULL THEN -1
        WHEN md.is_prev_word_from_or_join_keyword = 1 
        THEN md.ni_ordering - 2
        ELSE -1
      END
        
      WHERE md.tx_sql NOT IN ('FROM', 'JOIN', 'INNER', 'CROSS', 'LEFT', 'RIGHT');

      IF (@ip_is_debugging = 1) BEGIN SELECT * FROM #ni ORDER BY ni_ordering; END

    END

    IF (1=1 /* "Temp"-table: ls -> Last "ni_ordering" */) BEGIN
      DROP TABLE IF EXISTS #ls; SELECT 
        MAX(ni.ni_ordering) AS ni_ordering
      INTO #ls
      FROM #ni AS ni;
      IF (@ip_is_debugging = 1) BEGIN SELECT * FROM #ls; END

    END

    IF (1=1 /* "Temp"-table: ds -> Ordering for only "Datasets" . */) BEGIN
      DROP TABLE IF EXISTS #ds; SELECT
        ni.cd_join_type     AS cd_join_type, 
        ni.id_dataset       AS id_dataset,
        ni.id_source_model  AS id_source_model,
        ni.nm_target_schema AS nm_target_schema,
        ni.nm_target_table  AS nm_target_table,
        ni.cd_alias         AS cd_alias,
        ni.ni_ordering +1   AS ni_ordering_from,
        ISNULL( /*          AS ni_ordering_till */
            LEAD(ni.ni_ordering) OVER ( 
            PARTITION BY ls.ni_ordering ORDER BY ls.ni_ordering ASC
            )-1, ls.ni_ordering
        ) AS ni_ordering_till
      INTO #ds
      FROM #ni AS ni CROSS JOIN #ls AS ls
      WHERE ni.id_dataset IS NOT NULL;
      IF (@ip_is_debugging = 1) BEGIN SELECT * FROM #ds; END

    END
    
    IF (1=1 /* "Temp"-table: rs -> "Resultset". */) BEGIN
      DROP TABLE IF EXISTS #tsa_transformation_dataset; SELECT
        @ip_id_transformation_part               AS id_transformation_part,
        LOWER(CONVERT(CHAR(32),HASHBYTES( /*     AS id_transformation_dataset */
        'MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''),
        '|', @ip_id_transformation_part,
        '|', ds.id_dataset,
        '|', ds.cd_alias,
        '|')),2)) AS id_transformation_dataset,
        ROW_NUMBER() OVER ( /*                   AS ni_transformation_dataset */
          PARTITION BY 1 ORDER BY ds.ni_ordering_from
        ) AS ni_transformation_dataset, 
        ds.cd_join_type                          AS cd_join_type,
        ds.id_source_model                       AS id_source_model,
        ds.id_dataset                             AS id_dataset,
        ds.nm_target_schema                      AS nm_target_schema,
        ds.nm_target_table                       AS nm_target_table,
        ds.cd_alias                               AS cd_alias, 
        STRING_AGG(ISNULL(md.tx_sql,''), ' ') /* AS tx_join_criteria */ 
            WITHIN GROUP (ORDER BY ISNULL(md.ni_ordering, 0) ASC
        ) AS tx_join_criteria
      INTO #tsa_transformation_dataset
      FROM #ds AS ds LEFT JOIN #ni AS md 
      ON  md.ni_ordering BETWEEN ds.ni_ordering_from AND ds.ni_ordering_till
      AND md.tx_sql NOT IN ('INNER', 'CROSS', 'LEFT', 'RIGHT', 'FULL', 'JOIN', 'FORM', 'AS', 'ON')
      AND md.tx_sql NOT IN (ds.nm_target_schema, ds.nm_target_table, ds.cd_alias)          
      GROUP BY ni_ordering_from,
              ds.cd_join_type,
              ds.id_source_model,
              ds.id_dataset,
              ds.nm_target_schema,
              ds.nm_target_table,
              ds.cd_alias;
      IF (@ip_is_debugging = 1) BEGIN SELECT * FROM #tsa_transformation_dataset; END

    END;

    IF (@ip_is_testing = 0 /* If NOT in Testing-mode */) BEGIN
      INSERT INTO tsa_dta.tsa_transformation_dataset (
        id_model, id_transformation_part, id_transformation_dataset, ni_transformation_dataset, cd_join_type, id_source_model, id_dataset, cd_alias, tx_join_criteria
      ) SELECT 
        @id_model, id_transformation_part, id_transformation_dataset, ni_transformation_dataset, cd_join_type, id_source_model, id_dataset, cd_alias, tx_join_criteria 
      FROM #tsa_transformation_dataset;
    END
  
  END TRY
  BEGIN CATCH

    /* If an error occurs, show the error message. */
    SET @tx_error_message = '--- Error in usp_transformation_dataset: ---------------------------------------'
               + CHAR(10) + '-- Message  : ' + ERROR_MESSAGE()
               + CHAR(10) + '-- Line     : ' + CONVERT(NVARCHAR(10), ERROR_LINE())
               + CHAR(10) + '-- State    : ' + CONVERT(NVARCHAR(10), ERROR_STATE()) 
               + CHAR(10) + '-- Severity : ' + CONVERT(NVARCHAR(10), ERROR_SEVERITY());
    SET @tx_sql_execution = 'EXEC deployment.usp_transformation_dataset '
               + CHAR(10) + '  @ip_id_transformation_part = ''' + @ip_id_transformation_part + ''','
               + CHAR(10) + '  @ip_tx_transformation_part = ''' + REPLACE(@ip_tx_transformation_part, '''', '''''') + ''','
               + CHAR(10) + '  @ip_is_debugging           = 1,'
               + CHAR(10) + '  @ip_is_testing             = 0;';
    PRINT('')
    PRINT(@tx_error_message);
    PRINT(@tx_sql_execution);
    PRINT('');
   
  END CATCH
END
GO