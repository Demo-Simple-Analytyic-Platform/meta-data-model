CREATE PROCEDURE [deployment].[usp_dq_aggregates_as_datasets_for_totals] AS BEGIN 

DECLARE 
  @id_model              CHAR(32) = (SELECT id_model              FROM mdm.current_model);

  DECLARE
    @id_development_status CHAR(32) = (SELECT id_development_status FROM srd.development_status WHERE meta_is_active = 1 AND id_model = @id_model AND cd_development_status = 'PRD'),
    @id_datatype_ch        CHAR(32) = (SELECT id_datatype           FROM srd.datatype           WHERE meta_is_active = 1 AND id_model = @id_model AND cd_target_datatype    = 'CHAR(32)'),
    @id_datatype_int       CHAR(32) = (SELECT id_datatype           FROM srd.datatype           WHERE meta_is_active = 1 AND id_model = @id_model AND cd_target_datatype    = 'INT'),
    @ni_level              INT      = 1,
    @ni_inserted           INT,
    @tx_next_ddl_query_part NVARCHAR(MAX)
  BEGIN
    SET @tx_next_ddl_query_part = ''
      + 'SELECT "<@id_dq_control>"    AS id_dq_control,'
      +       ' dqt.dt_dq_result      AS dt_dq_result,'
      +       ' dqt.ni_oke            AS ni_oke,'
      +       ' dqt.ni_nok            AS ni_nok,'
      +       ' dqt.ni_oos            AS ni_oos,'
      +       ' dqt.ni_total_excl_oos AS ni_total_excl_oos,'
      +       ' dqt.ni_total_incl_oos AS ni_total_incl_oos '
      + 'FROM [dq_totals].[dqt_<@id_dq_control>] AS dqt'

    IF (1=1) BEGIN PRINT('/* Extract "DQ Controls" with "Created At"-dattime. */')
      DROP TABLE IF EXISTS #dqc; 
      SELECT dqc.id_dataset, dqc.id_dq_control, MIN(meta_dt_valid_from) AS dt_created_at
      INTO #dqc
      FROM dqm.dq_control AS dqc
      WHERE dqc.meta_is_active = 1 AND id_model = @id_model
      GROUP BY  id_dataset, id_dq_control;
    END
    IF (1=1) BEGIN PRINT('/* Extract definitions of "DQ Totals"-datasets. */');
      DROP TABLE IF EXISTS #rst;
      SELECT dst.id_dataset, dst.fn_dataset, dst.nm_target_schema AS nm_source_schema, dst.nm_target_table  AS nm_source_table
      INTO #rst
      FROM dta.dataset AS dst
      WHERE dst.meta_is_active = 1 AND id_model = @id_model
      AND   SUBSTRING(dst.nm_target_table,1,3) = 'dqt'
    END
    IF (1=1) BEGIN PRINT('/* Add ROW_NUMBER() for "dataset" and "Ordering" by "Created At". */');
      DROP TABLE IF EXISTS #agg;
      SELECT rst.id_dataset,
             dqc.id_dq_control,
             rst.nm_source_schema,
             rst.nm_source_table, 
             dqc.dt_created_at,
             1                                                     AS ni_next_level,
             (ROW_NUMBER()  OVER (ORDER BY dqc.dt_created_at))     AS ni_next_ordering,
             (ROW_NUMBER()  OVER (ORDER BY dqc.dt_created_at) % 2) AS ni_next_dataset,
             ((ROW_NUMBER() OVER (ORDER BY dqc.dt_created_at)) + (ROW_NUMBER() OVER (ORDER BY dqc.dt_created_at) % 2)) / 2 AS ni_next_sub_level,
             LOWER(CONVERT(CHAR(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''),
               '|', 'DQ Total (Agg) - Level',
               '|', 1,
               '|', (((ROW_NUMBER() OVER (ORDER BY dqc.dt_created_at)) + (ROW_NUMBER() OVER (ORDER BY dqc.dt_created_at) % 2)) / 2),
               '|')),2)) AS id_next_dataset,
              ((CASE WHEN (ROW_NUMBER()  OVER (ORDER BY dqc.dt_created_at) % 2) = 1 THEN '' ELSE ' UNION ALL ' END) +
              REPLACE(@tx_next_ddl_query_part, '<@id_dq_control>', dqc.id_dq_control)) AS tx_next_ddl_query_part
      INTO #agg
      FROM #dqc AS dqc JOIN #rst AS rst ON rst.fn_dataset LIKE '%'+dqc.id_dq_control+'%';
      --select * from #agg
    END
    IF (1=1) BEGIN PRINT('/* Construct "Definitions for Level 1 "Unions" of the "DQ Results". */');
      SET @tx_next_ddl_query_part = ''
        + 'SELECT dqa.id_dq_control     AS id_dq_control,'
        +       ' dqa.dt_dq_result      AS dt_dq_result,'
        +       ' dqa.ni_oke            AS ni_oke,'
        +       ' dqa.ni_nok            AS ni_nok,'
        +       ' dqa.ni_oos            AS ni_oos,'
        +       ' dqa.ni_total_excl_oos AS ni_total_excl_oos,'
        +       ' dqa.ni_total_incl_oos AS ni_total_incl_oos '
        + 'FROM [dta_dq_aggregates].[dqa_<@q0.id_next_dataset>] AS dqa'
      DROP TABLE IF EXISTS #dta_dataset; 
      SELECT /* Helper Attribute for "next" iteration. */
             q0.ni_next_level + 1                                     AS ni_next_level,
             (ROW_NUMBER()   OVER (ORDER BY q0.ni_next_ordering))     AS ni_next_ordering,
             (ROW_NUMBER()   OVER (ORDER BY q0.ni_next_ordering) % 2) AS ni_next_dataset,
             (((ROW_NUMBER() OVER (ORDER BY q0.ni_next_ordering)) + (ROW_NUMBER() OVER (ORDER BY q0.ni_next_ordering) % 2)) / 2) AS ni_next_sub_level,
             LOWER(CONVERT(CHAR(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''),
               '|', 'DQ Total (Agg) - Level',
               '|', q0.ni_next_level + 1,             
               '|', (((ROW_NUMBER() OVER (ORDER BY q0.ni_next_ordering)) + (ROW_NUMBER() OVER (ORDER BY q0.ni_next_ordering) % 2)) / 2),
               '|')),2)) AS id_next_dataset,
              ((CASE WHEN (ROW_NUMBER()  OVER (ORDER BY q0.ni_next_ordering) % 2) = 1 THEN '' ELSE ' UNION ALL ' END) +
              REPLACE(@tx_next_ddl_query_part, '<@q0.id_next_dataset>', q0.id_next_dataset)) AS tx_next_ddl_query_part,
           
             /* Attributes for INSERT into tsa_dta.tsa_dataset. */
             q0.id_next_dataset            AS id_dataset,
             @id_development_status        AS id_development_status,
             NULL                          AS id_group,
             0                             AS is_ingestion,
             CONVERT(NVARCHAR(128), CONCAT('DQ Result (Agg) - Level ', q0.ni_next_level, '.', q0.ni_next_sub_level)) AS fn_dataset,
             CONVERT(NVARCHAR(999), 'This will aggregate the \"DQ Result\" of `' + q0.id_dq_control+'` and `' + q0.id_dq_control+'` into new dataset.') AS fd_dataset,
             'dta_dq_aggregates'           AS nm_target_schema,
             CONCAT('dqa_', q0.id_next_dataset) AS nm_target_table,
             CONVERT(NVARCHAR(MAX), (q0.tx_next_ddl_query_part + ISNULL(q1.tx_next_ddl_query_part,''))) AS tx_source_query
      INTO #dta_dataset
      FROM      (SELECT * FROM #agg WHERE ni_next_dataset = 1) AS q0 
      LEFT JOIN (SELECT * FROM #agg WHERE ni_next_dataset = 0) AS q1 
      ON q1.id_next_dataset = q0.id_next_dataset;
      SET @ni_inserted = @@ROWCOUNT;
      --SELECT * FROM #dta_dataset;
    END

    WHILE (@ni_inserted != 0) BEGIN print('/* Add more "Aggregations" of "DQ Results" to "Definitons"-datasets. */');

      PRINT(CONCAT('/* @ni_level    : ', @ni_level, ' */'));
      PRINT(CONCAT('/* @ni_inserted : ', @ni_inserted, ' */'));
    
      /* Add 1 to "Next"-level. */
      SET @ni_level += 1;

      INSERT INTO #dta_dataset (
    
        /* Helper Attribute for "next" iteration. */
        ni_next_level, ni_next_ordering, ni_next_dataset, ni_next_sub_level, id_next_dataset, tx_next_ddl_query_part, 
      
        /* Attributes for INSERT into tsa_dta.tsa_dataset. */
        id_dataset, id_development_status, id_group, is_ingestion, fn_dataset, fd_dataset, nm_target_schema, nm_target_table, tx_source_query
	
	    )
      SELECT /* Helper Attribute for "next" iteration. */
             q0.ni_next_level + 1                                     AS ni_next_level,
             (ROW_NUMBER()   OVER (ORDER BY q0.ni_next_ordering))     AS ni_next_ordering,
             (ROW_NUMBER()   OVER (ORDER BY q0.ni_next_ordering) % 2) AS ni_next_dataset,
             (((ROW_NUMBER() OVER (ORDER BY q0.ni_next_ordering)) + (ROW_NUMBER() OVER (ORDER BY q0.ni_next_ordering) % 2)) / 2) AS ni_next_sub_level,
             LOWER(CONVERT(CHAR(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''),
               '|', 'DQ Total (Agg) - Level',
               '|', q0.ni_next_level + 1,             
               '|', (((ROW_NUMBER() OVER (ORDER BY q0.ni_next_ordering)) + (ROW_NUMBER() OVER (ORDER BY q0.ni_next_ordering) % 2)) / 2),
               '|')),2)) AS id_next_dataset,
              ((CASE WHEN (ROW_NUMBER()  OVER (ORDER BY q0.ni_next_ordering) % 2) = 1 THEN '' ELSE ' UNION ALL ' END) +
             REPLACE(@tx_next_ddl_query_part, '<@q0.id_next_dataset>', q0.id_next_dataset)) AS tx_next_ddl_query_part,
                      
             /* Attributes for INSERT into tsa_dta.tsa_dataset. */
             q0.id_next_dataset              AS id_dataset,
             @id_development_status          AS id_development_status,
             NULL                            AS id_group,
             0                               AS is_ingestion,
             CASE /*                         AS fn_dataset, */
               WHEN @ni_inserted = 2 
               THEN 'DQ Totals' 
               ELSE CONVERT(NVARCHAR(128), 'DQ Totals (Agg) - Level ' + CONVERT(NVARCHAR(32), q0.ni_next_level)+ '.' + FORMAT(q0.ni_next_sub_level,'N0')) END AS fn_dataset,
             CASE /*                         AS fd_dataset, */
               WHEN @ni_inserted = 2 
               THEN 'This \"Dataset\" has an \"Aggregation\" of all \"DQ Totals\" for all \"DQ Controls\".' 
               ELSE CONVERT(NVARCHAR(999), 'This will aggregate the \"DQ Totals\" of `' + q0.id_dataset+'` and `' + q0.id_dataset+'` into new dataset.') END AS fd_dataset,
             CASE /*                         AS nm_target_schema, */
               WHEN @ni_inserted = 2 
               THEN 'dqm' 
               ELSE 'dta_dq_aggregates' END AS nm_target_schema,
             CASE  /*                        AS nm_target_table, */
               WHEN @ni_inserted = 2 
               THEN 'dq_totals'
               ELSE CONCAT('dqa_', q0.id_next_dataset) END AS nm_target_table,
             (q0.tx_next_ddl_query_part + ISNULL(q1.tx_next_ddl_query_part,'')) AS tx_source_query
      FROM      (SELECT * FROM #dta_dataset WHERE ni_next_dataset = 1 AND ni_next_level = @ni_level) AS q0 
      LEFT JOIN (SELECT * FROM #dta_dataset WHERE ni_next_dataset = 0 AND ni_next_level = @ni_level) AS q1
      ON q1.id_next_dataset = q0.id_next_dataset;
      SET @ni_inserted = @@ROWCOUNT;
      --SELECT * FROM #dta_dataset;

      /* Determine if "Last"-aggragation. */
    
      IF (@ni_inserted = 1) BEGIN PRINT('/* Is "Last"-aggregation of "DQ Totals". */');
        SET @ni_inserted = 0;
      END
    END

    IF (1=1) BEGIN PRINT('/* Insert "Dataset"-definitions of "Aggragate"-datasets. */');
      INSERT INTO tsa_dta.tsa_dataset (id_model, id_dataset, id_development_status, id_group, is_ingestion, fn_dataset, fd_dataset, nm_target_schema, nm_target_table, tx_source_query)
      SELECT @id_model, id_dataset, id_development_status, id_group, is_ingestion, fn_dataset, fd_dataset, nm_target_schema, nm_target_table, tx_source_query
      FROM #dta_dataset;
    END

    IF (1=1) BEGIN PRINT('/* Construct "Definitions for Level 1 "Attributes" of"Unions" of the "DQ Results". */');
      INSERT INTO tsa_dta.tsa_attribute (id_model, id_attribute, id_dataset, id_datatype, fn_attribute, fd_attribute, ni_ordering, nm_target_column, is_businesskey, is_nullable) SELECT     
        id_model         = @id_model,
        id_attribute     = LOWER(CONVERT(char(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''), '|dqt|', dst.id_dataset, '|', col.nm_target_column, '|')), 2)),
        id_dataset       = dst.id_dataset,
        id_datatype      = col.id_datatype,
        fn_attribute     = col.fn_attribute,
        fd_attribute     = col.fd_attribute,
        ni_ordering      = col.ni_ordering,
        nm_target_column = col.nm_target_column,
        is_businesskey   = col.is_businesskey,
        is_nullable      = 0
    
      FROM #dta_dataset AS dst CROSS JOIN ( SELECT v.is_businesskey, v.ni_ordering, v.nm_target_column, v.fn_attribute, v.fd_attribute, d.id_datatype FROM (VALUES 
		    (1, 1, 'id_dq_control',    'id', 'ID DQ Control',       'Reference to \"DQ Control\".'),
        (1, 2, 'dt_dq_result',     'dt', 'DQ Result Date',      'Reference to \"DQ Result Status\".'), 
		    (0, 3, 'ni_oke',           'ni', '# Oke',               'The # Records that have \"Status\" Oke.'), 
		    (0, 4, 'ni_nok',           'ni', '# Not Oke',           'The # Records that have \"Status\" Not Oke.'), 
		    (0, 5, 'ni_oos',           'ni', '# Out of Scope',      'The # Records that have \"Status\" Out of Scope.'), 
		    (0, 6, 'ni_total_excl_oos','ni', '# Total (excl. OOS)', 'The # Total excluding \"Out of Scop\"-status.'), 
		    (0, 7, 'ni_total_incl_oos','ni', '# Total (incl. OOS)', 'The # Total including \"Out of Scop\"-status.') 
	    ) As v (is_businesskey,ni_ordering, nm_target_column, cd_prefix_column_name, fn_attribute, fd_attribute)
      LEFT JOIN tsa_srd.tsa_datatype AS d ON d.cd_prefix_column_name = v.cd_prefix_column_name
      ) AS col;    
    END

    /* Add "meta"-attribute to "Attribute"-definitions. */
    EXEC deployment.usp_add_all_meta_attributes;
    
  END
END
GO