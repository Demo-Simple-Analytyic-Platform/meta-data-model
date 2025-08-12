CREATE PROCEDURE deployment.usp_insert_dq_controls_as_datasets AS DECLARE

  @id                    CHAR(32),
  @id_model              CHAR(32),
  @id_dq_control         CHAR(32),
  @id_development_status CHAR(32),
  @fn_dq_control         NVARCHAR(128),
  @fd_dq_control         NVARCHAR(999),
  @nm_target_schema      NVARCHAR(128),
  @nm_target_table       NVARCHAR(128),
  @tx_dq_control_query   NVARCHAR(MAX),

  @id_dq_result_status_oke NVARCHAR(34),
  @id_dq_result_status_nok NVARCHAR(34),
  @id_dq_result_status_oos NVARCHAR(34),

  /* Helper for Debugging */
  @msg NVARCHAR(999) = '',
  @sql NVARCHAR(MAX) = '',
  @emp NVARCHAR(1)   = '',
  @nwl NVARCHAR(9)   = '<newline>',
  @vld BIT           = 0

BEGIN

  DROP TABLE IF EXISTS #dqc; SELECT id_dq_control AS id, id_model INTO #dqc FROM tsa_dqm.tsa_dq_control WHERE LEN(ISNULL(tx_dq_control_query,'')) > 10;
  WHILE ((SELECT COUNT(*) FROM #dqc) > 0) BEGIN
    
    /* Fetch next "record". */
    SELECT @id = id, @id_model = id_model FROM (SELECT TOP 1 id, id_model FROM #dqc) AS rec; DELETE FROM #dqc WHERE id = @id AND id_model = @id_model;
    
    IF (1=1 /* Generate "Dataset"- and "Attribute"- definitions for the "DQ Control"-results. */) BEGIN
  
      /* Extract "DQ Control". */
      SELECT @id_dq_control         = LOWER(CONVERT(CHAR(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''), '|', id_model, '|', id_dq_control, '|', 'result', '|')), 2)),
             @id_development_status = id_development_status,
             @fn_dq_control         = fn_dq_control,
             @fn_dq_control         = 'Is `Dataset`-definition for `DQ Control`-result of '+@id+' with functional description of `' + @id + '`.',
             @nm_target_schema      = 'dq_result', 
             @nm_target_table       = 'dqr_' + @id, 
             @tx_dq_control_query   = tx_dq_control_query
      FROM tsa_dqm.tsa_dq_control 
      WHERE id_dq_control = @id
      AND   id_model      = @id_model;

      /* Extent "DQ Control"-query. */
      SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '''', '"');
  
      SET @id_dq_result_status_oke = '"' + gnc_commen.tsa_id_dq_result_status(@id_model, 'OKE') + '"';
      SET @id_dq_result_status_nok = '"' + gnc_commen.tsa_id_dq_result_status(@id_model, 'NOK') + '"';
      SET @id_dq_result_status_oos = '"' + gnc_commen.tsa_id_dq_result_status(@id_model, 'OOS') + '"';

      IF (1=1 /* Convert "OKE" to "ID". */) BEGIN
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"OK"',  @id_dq_result_status_oke);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"ok"',  @id_dq_result_status_oke);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"Ok"',  @id_dq_result_status_oke);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"oK"',  @id_dq_result_status_oke);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"OKE"', @id_dq_result_status_oke);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"Oke"', @id_dq_result_status_oke);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"oKe"', @id_dq_result_status_oke);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"okE"', @id_dq_result_status_oke);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"OKe"', @id_dq_result_status_oke);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"oKE"', @id_dq_result_status_oke);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"OkE"', @id_dq_result_status_oke);
      END
      IF (1=1 /* Convert "NOK" to "ID". */) BEGIN
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"NOK"', @id_dq_result_status_nok);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"nok"', @id_dq_result_status_nok);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"Nok"', @id_dq_result_status_nok);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"nOk"', @id_dq_result_status_nok);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"noK"', @id_dq_result_status_nok);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"NOk"', @id_dq_result_status_nok);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"nOK"', @id_dq_result_status_nok);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"NoK"', @id_dq_result_status_nok);
      END
      IF (1=1 /* Convert "OOS" to "ID". */) BEGIN
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"OOS"', @id_dq_result_status_oos);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"oos"', @id_dq_result_status_oos);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"Oos"', @id_dq_result_status_oos);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"oOs"', @id_dq_result_status_oos);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"ooS"', @id_dq_result_status_oos);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"OOs"', @id_dq_result_status_oos);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"oOS"', @id_dq_result_status_oos);
        SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"OoS"', @id_dq_result_status_oos);
      END
      SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"', '''');

      IF (1=1 /* Validation if all "Query" of "DQ Control" has the right format. */) BEGIN
        
        SELECT @vld = CASE
          WHEN @tx_dq_control_query LIKE 'SELECT'
                                       + '% AS id_dataset_1_bk,'
                                       + '% AS id_dataset_2_bk,'
                                       + '% AS id_dataset_3_bk,'
                                       + '% AS id_dataset_4_bk,'
                                       + '% AS id_dataset_5_bk,'
                                       + '%CASE%WHEN%ELSE%END AS id_dq_result_status'
                                       + '%FROM%'
          THEN 1
          ELSE 0
        END 

        IF (@vld=0) BEGIN
          SET @msg = 'DQ Control `' + @id_dq_control + '` has not the correct format!'
            + @nwl + 'Expected format for query: "'
            + @nwl + 'SELECT'
            + @nwl + '% AS id_dataset_1_bk,'
            + @nwl + '% AS id_dataset_2_bk,'
            + @nwl + '% AS id_dataset_3_bk,'
            + @nwl + '% AS id_dataset_4_bk,'
            + @nwl + '% AS id_dataset_5_bk,'
            + @nwl + '%CASE%WHEN%ELSE%END AS id_dq_result_status'
            + @nwl + '%FROM%'
            + @nwl + 'DQ Control Query : "' + @tx_dq_control_query + '"';

          RAISERROR(@msg, 16, 1);
        END

      END

      INSERT INTO tsa_dta.tsa_dataset (id_model, id_dataset, id_development_status, id_group, is_ingestion, fn_dataset, fd_dataset, nm_target_schema, nm_target_table, tx_source_query) SELECT 
        id_model              = @id_model,
        id_dataset            = @id_dq_control,
        id_development_status = @id_development_status,
        id_group              = NULL,
        is_ingestion          = 0, 
        fn_dataset            = @fn_dq_control,
        fd_dataset            = @fd_dq_control,
        nm_target_schema      = @nm_target_schema,
        nm_target_table       = @nm_target_table,
        tx_source_query       = @tx_dq_control_query;
  
      INSERT INTO tsa_dta.tsa_attribute (id_model,id_attribute, id_dataset, id_datatype, fn_attribute, fd_attribute, ni_ordering, nm_target_column, is_businesskey, is_nullable) SELECT
        id_model         = @id_model,
        id_attribute     = LOWER(CONVERT(char(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''), @id_dq_control, '|', col.nm_target_column, '|')), 2)),
        id_dataset       = @id_dq_control,
        id_datatype      = (SELECT id_datatype from tsa_srd.tsa_datatype WHERE cd_target_datatype = 'CHAR(32)'),
        fn_attribute     = col.fn_attribute,
        fd_attribute     = col.fd_attribute,
        ni_ordering      = col.ni_ordering,
        nm_target_column = col.nm_target_column,
        is_businesskey   = IIF(nm_target_column IN ('id_dq_result_status'), 0, 1),
        is_nullable      = 0

      FROM ( SELECT v.ni_ordering, v.nm_target_column, v.fn_attribute, v.fd_attribute FROM (VALUES 
		    (1, 'id_dataset_1_bk',     'ID Dataset 1 BK', 'The \"Businesskey Hash\"-value of the \"Record\" from \"Dataset 1\" checked by the \"DQ Control\".'),
        (2, 'id_dataset_2_bk',     'ID Dataset 1 BK', 'The \"Businesskey Hash\"-value of the \"Record\" from \"Dataset 2\" checked by the \"DQ Control\".'),
        (3, 'id_dataset_3_bk',     'ID Dataset 1 BK', 'The \"Businesskey Hash\"-value of the \"Record\" from \"Dataset 3\" checked by the \"DQ Control\".'),
        (4, 'id_dataset_4_bk',     'ID Dataset 1 BK', 'The \"Businesskey Hash\"-value of the \"Record\" from \"Dataset 4\" checked by the \"DQ Control\".'),
        (5, 'id_dataset_5_bk',     'ID Dataset 1 BK', 'The \"Businesskey Hash\"-value of the \"Record\" from \"Dataset 5\" checked by the \"DQ Control\".'),
        (6, 'id_dq_result_status', 'ID DQ Result Status', 'Reference to \"DQ Result Status\".') 
	    ) As v (ni_ordering, nm_target_column, fn_attribute, fd_attribute)) AS col;
  
    END
    IF (1=1 /* Generate "Dataset"- and "Attribute"- definitions for the "DQ Control"-totals. */) BEGIN

      /* Extract "DQ Control". */
      SELECT @id_dq_control         = LOWER(CONVERT(CHAR(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''), '|', id_dq_control, '|', 'totals', '|')), 2)),
             @id_development_status = id_development_status,
             @fn_dq_control         = fn_dq_control,
             @fn_dq_control         = 'Is `Dataset`-definition for `DQ Control`-totals of \"DQ Control\" `'+@id+'`.',
             @nm_target_schema      = 'dq_totals', 
             @nm_target_table       = 'dqt_' + @id_dq_control, 
             @tx_dq_control_query   = 'SELECT CONVERT(DATE, @dt_current_stand)                                                               AS dt_dq_result,'
                             + @nwl + '       SUM(CASE WHEN dqr.id_dq_result_status  = ' + @id_dq_result_status_oke + ' THEN 1 ELSE 0 END) AS ni_oke,'
                             + @nwl + '       SUM(CASE WHEN dqr.id_dq_result_status  = ' + @id_dq_result_status_nok + ' THEN 1 ELSE 0 END) AS ni_nok,'
                             + @nwl + '       SUM(CASE WHEN dqr.id_dq_result_status  = ' + @id_dq_result_status_oos + ' THEN 1 ELSE 0 END) AS ni_oos,'
                             + @nwl + '       SUM(CASE WHEN dqr.id_dq_result_status != ' + @id_dq_result_status_oos + ' THEN 1 ELSE 0 END) AS ni_total_excl_oos,'
                             + @nwl + '       SUM(1)                                                                                         AS ni_total_incl_oos'
                             + @nwl + 'FROM dq_result.dqr_' + @id + ' AS dqr' 
                             + @nwl + 'WHERE dqr.meta_dt_valid_from <= CONVERT(DATETIME, @dt_current_stand)'
                             + @nwl + 'AND   dqr.meta_dt_valid_till >  CONVERT(DATETIME, @dt_current_stand)'

      FROM tsa_dqm.tsa_dq_control WHERE id_dq_control = @id AND id_model = @id_model;
      SET @tx_dq_control_query = REPLACE(@tx_dq_control_query, '"', '''');

      INSERT INTO tsa_dta.tsa_dataset (id_model, id_dataset, id_development_status, id_group, is_ingestion, fn_dataset, fd_dataset, nm_target_schema, nm_target_table, tx_source_query) SELECT 
        id_model              = @id_model,
        id_dataset            = @id_dq_control,
        id_development_status = @id_development_status,
        id_group              = NULL,
        is_ingestion          = 0, 
        fn_dataset            = @fn_dq_control,
        fd_dataset            = @fd_dq_control,
        nm_target_schema      = @nm_target_schema,
        nm_target_table       = @nm_target_table,
        tx_source_query       = @tx_dq_control_query;
  
      INSERT INTO tsa_dta.tsa_attribute (id_model, id_attribute, id_dataset, id_datatype, fn_attribute, fd_attribute, ni_ordering, nm_target_column, is_businesskey, is_nullable) SELECT
        id_model         = @id_model,
        id_attribute     = LOWER(CONVERT(char(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''), @id_dq_control, '|', col.nm_target_column, '|')), 2)),
        id_dataset       = @id_dq_control,
        id_datatype      = col.id_datatype,
        fn_attribute     = col.fn_attribute,
        fd_attribute     = col.fd_attribute,
        ni_ordering      = col.ni_ordering,
        nm_target_column = col.nm_target_column,
        is_businesskey   = col.is_businesskey,
        is_nullable      = 0

      FROM ( SELECT v.is_businesskey, v.ni_ordering, v.nm_target_column, v.fn_attribute, v.fd_attribute, d.id_datatype FROM (VALUES 
		    (1, 1, 'dt_dq_result',     'dt', 'DQ Result Date',      'Reference to \"DQ Result Status\".'), 
		    (0, 2, 'ni_oke',           'ni', '# Oke',               'The # Records that have \"Status\" Oke.'), 
		    (0, 3, 'ni_nok',           'ni', '# Not Oke',           'The # Records that have \"Status\" Not Oke.'), 
		    (0, 4, 'ni_oos',           'ni', '# Out of Scope',      'The # Records that have \"Status\" Out of Scope.'), 
		    (0, 5, 'ni_total_excl_oos','ni', '# Total (excl. OOS)', 'The # Total excluding \"Out of Scop\"-status.'), 
		    (0, 6, 'ni_total_incl_oos','ni', '# Total (incl. OOS)', 'The # Total including \"Out of Scop\"-status.') 
	    ) As v (is_businesskey,ni_ordering, nm_target_column, cd_prefix_column_name, fn_attribute, fd_attribute)
      LEFT JOIN tsa_srd.tsa_datatype AS d ON d.cd_prefix_column_name = v.cd_prefix_column_name
      ) AS col;
      
    END

  END
END
GO