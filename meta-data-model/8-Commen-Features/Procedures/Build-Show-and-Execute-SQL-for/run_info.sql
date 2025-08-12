CREATE PROCEDURE rdp.run_info
  
	/* Input Paramters. */
	@ip_id_model   CHAR(32),
  @ip_id_dataset CHAR(32),

  /* Paramters for "Debugging". */
  @ip_is_debugging     BIT = 0,
  @ip_is_testing       BIT = 0

AS DECLARE
  
	/* Local Variables for "Extraction" or " Processing Infromation". */
	@is_ingestion     BIT = 0,
	@is_sql_source    BIT = IIF(LOWER(gnc_commen.tx_parameter_value(@ip_id_model, @ip_id_dataset, 'adf_2_cd_source_dataset_type')) = 'sql', 1, 0),

	@sql_rst_parameters NVARCHAR(MAX) = '',
	@nm_target_column   NVARCHAR(128),
	@nm_parameter       NVARCHAR(128),
	@tx_parameter_value NVARCHAR(MAX),
  @ni_parameter_value INT,

	/* Local Variables for "Extraction" or " Processing Infromation". */
	@nm_target_schema   NVARCHAR(128),
	@nm_target_table    NVARCHAR(128),
	@tx_source_query    NVARCHAR(MAX),

	/* Local Varaibles for "SQL" for "Metadata"-attributes. */
	@nm_processing_type            NVARCHAR(128),
	@tx_sql_for_meta_dt_valid_from NVARCHAR(MAX),
	@tx_sql_for_meta_dt_valid_till NVARCHAR(MAX),

	/* Local Variables for "Timestamp/Epoch". */
	@dt_previous_stand NVARCHAR(32),
	@dt_current_stand	 NVARCHAR(32),
	@ni_previous_epoch NVARCHAR(32),
	@ni_current_epoch	 NVARCHAR(32),
	@tx_sql_between    NVARCHAR(MAX),

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
				
	/* "Transformation"-datasets */
	@id_transformation_dataset       CHAR(32),
	@tx_sql_for_replace_from_dataset NVARCHAR(MAX),
	@cd_alias_for_from               NVARCHAR(MAX),
	@cd_alias_for_full_join          NVARCHAR(MAX),

	/* Local Varaible for Building SQL Statements. */
	@message NVARCHAR(999),
  @src NVARCHAR(MAX),
  @tgt NVARCHAR(MAX),
	@att NVARCHAR(MAX) = '',
	@col NVARCHAR(MAX) = '',
	@emp NVARCHAR(1)   = '',
	@sqt NVARCHAR(1)   = '''',
	@nwl NVARCHAR(1)   = CHAR(10),
	@sql NVARCHAR(MAX) = '',
	@qry NVARCHAR(MAX) = '',
	@ddl NVARCHAR(MAX) = '',
  @tb1 NVARCHAR(32)  = CHAR(10) + '  ',
  @tb2 NVARCHAR(32)  = CHAR(10) + '    ',
  @tb3 NVARCHAR(32)  = CHAR(10) + '      ',
	@nl  NVARCHAR(1)   = CHAR(10),
	
	/* Local Varaibles for "SQL" for "Metadata"-attributes. */
  @rwh NVARCHAR(MAX) = '',
  @bks NVARCHAR(MAX) = '',
  @pks NVARCHAR(MAX) = '',
  @ord INT,
  @idx INT = 0,
  @max INT = 100

	
BEGIN

	IF (1=1 /* Extract all "parameters" for "Dataset". */) BEGIN 
		DROP TABLE IF EXISTS #ptr; SELECT
			nm_parameter       = ptr.nm_parameter,
			tx_parameter_value = vlp.tx_parameter_value,
			ni_parameter_value = vlp.ni_parameter_value
		INTO #ptr 
		FROM dta.parameter_value AS vlp 
		JOIN srd.parameter AS ptr 
		ON  ptr.meta_is_active = 1 
		AND ptr.id_parameter   = vlp.id_parameter
		AND ptr.id_model       = vlp.id_model
		WHERE vlp.meta_is_active = 1 
		AND   vlp.id_dataset     = @ip_id_dataset 
		AND   vlp.id_model       = @ip_id_model;

		IF (@ip_is_debugging=1) BEGIN SELECT * FROM #ptr; END;
	END

	IF (1=1 /* Extraction of "active"-run on the timestamp/epoch. */) BEGIN
		SELECT @dt_previous_stand = CONVERT(NVARCHAR(32), dt_previous_stand, 120)
         , @dt_current_stand  = CONVERT(NVARCHAR(32), dt_current_stand,  120)
         , @ni_previous_epoch = CONVERT(NVARCHAR(32), ni_previous_epoch)
         , @ni_current_epoch  = CONVERT(NVARCHAR(32), ni_current_epoch)
		FROM rdp.run WHERE id_run = rdp.get_id_run(@ip_id_model, @ip_id_dataset);
		SET @tx_sql_between = 'BETWEEN CONVERT(DATETIME, "<@dt_previous_stand>") AND CONVERT(DATETIME, "<@dt_current_stand>")';
	END

	/* Extract "Target"-schema and -table names, Indicator "Ingestion". */
	SELECT @nm_target_schema              = ISNULL(dst.nm_target_schema, 'n/a')
       , @nm_target_table               = ISNULL(dst.nm_target_table,  'n/a')
       , @tx_source_query               = ISNULL(dst.tx_source_query,  'n/a')
			 , @is_ingestion                  = ISNULL(dst.is_ingestion, 0)
			 , @nm_processing_type            = IIF(dst.nm_target_schema = 'dq_totals', 'Fullload',IIF(ISNULL(dst.is_ingestion, 0)=1, etl.nm_processing_type, 'Incremental'))
       , @tx_sql_for_meta_dt_valid_from = REPLACE(ISNULL(etl.tx_sql_for_meta_dt_valid_from,'n/a'), @sqt, '"')
       , @tx_sql_for_meta_dt_valid_till = REPLACE(ISNULL(etl.tx_sql_for_meta_dt_valid_till,'n/a'), @sqt, '"')
	
	FROM dta.dataset AS dst 
	
	LEFT JOIN dta.ingestion_etl AS etl 
	ON  etl.meta_is_active = 1 
	AND etl.id_model       = dst.id_model
	AND etl.id_dataset     = dst.id_dataset
	AND dst.is_ingestion   = 1
	
	WHERE dst.meta_is_active = 1 
	AND   dst.id_model       = @ip_id_model
	AND   dst.id_dataset     = @ip_id_dataset;
	
	IF (@ip_is_debugging=1) BEGIN PRINT('@tx_source_query : ' + @tx_source_query); end;


	IF (1=1 /* Extrent then "Source"-query with metadata-attributes so is can load data into "TSA"-table. */) BEGIN

    IF (1=1 /* Extract "Columns"-dataset, exclude the "meta-attributes. */) BEGIN
    
			DROP TABLE IF EXISTS #columns; SELECT 
				o = att.ni_ordering,
				c = att.nm_target_column 
			INTO #columns FROM dta.attribute AS att
			WHERE att.id_model       = @ip_id_model
			AND   att.id_dataset     = @ip_id_dataset
			AND   att.meta_is_active = 1
			ORDER BY ni_ordering ASC;
    
			DROP TABLE IF EXISTS #busineskeys; SELECT 
				o = att.ni_ordering,
				c = att.nm_target_column 
			INTO #busineskeys FROM dta.attribute AS att 
			WHERE att.id_model       = @ip_id_model
			AND   att.id_dataset     = @ip_id_dataset
			AND   att.meta_is_active = 1
			AND   att.is_businesskey = 1
			ORDER BY ni_ordering ASC;

			IF (@ip_is_debugging=1) BEGIN SELECT * FROM #columns; END;
			IF (@ip_is_debugging=1) BEGIN SELECT * FROM #busineskeys; END;

		END
		IF (1=1 /* String all the "Colums" in the "temp"-table together with "s."-alias, after drop the "temp"-table. */) BEGIN
	  
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
			
			PRINT(@rwh);
			PRINT(@pks);
			PRINT(@bks);

		END	

		IF (@is_ingestion = 1 /* Extent the "Source"-query */) BEGIN
		
			SET @tx_source_query = REPLACE(@tx_source_query, @nwl, @tb1);
			SET @idx = CHARINDEX('FROM', @tx_source_query, 1);
			SET @qry  = @emp + 'SELECT';
			SET @qry += @nwl + '  ' + REPLACE(@att, @nwl, @tb1);
			SET @qry += @emp +   '[main].[meta_dt_valid_from] AS [meta_dt_valid_from],';
			SET @qry += @nwl + '  [main].[meta_dt_valid_till] AS [meta_dt_valid_till],';
			SET @qry += @nwl + '  CONVERT(BIT, 1) AS [meta_is_active],';
			SET @qry += @nwl + '  CONVERT(CHAR(32), HASHBYTES("MD5", ' + @rwh + ', 2) AS [meta_ch_rh]';
			SET @qry += @nwl + '  CONVERT(CHAR(32), HASHBYTES("MD5", ' + @bks + ', 2) AS [meta_ch_bk]';
			SET @qry += @nwl + '  CONVERT(CHAR(32), HASHBYTES("MD5", ' + @pks + ', 2) AS [meta_ch_pk]';
			SET @qry += @nwl + 'FROM (';
			SET @qry += @nwl + '  ' + SUBSTRING(@tx_source_query, 1, @idx-1);
			SET @qry += @nwl + '  , meta_dt_valid_from = CONVERT(DATETIME, ' + @tx_sql_for_meta_dt_valid_from + ')';
			SET @qry += @nwl + '  , meta_dt_valid_till = CONVERT(DATETIME, ' + @tx_sql_for_meta_dt_valid_till + ')';
			SET @qry += @nwl + '  ' + SUBSTRING(@tx_source_query, @idx, LEN(@tx_source_query));
			SET @qry += @nwl + ') AS [main]';

		END
		IF (@is_ingestion = 0 /* Extent the "Transformation"-query */) BEGIN 
			
			IF (@ip_is_debugging=1) BEGIN
				PRINT('/* Extent the "Transformation"-query */');
			END

			IF (1=1 /* Determine if "FULL JOIN" or "UNION" is "used" for the "Transformations". */) BEGIN

				SELECT @is_full_join_used = CASE WHEN (COUNT(*)>0) THEN 1 ELSE 0 END
				FROM dta.transformation_dataset 
				WHERE meta_is_active = 1 
				AND   id_model       = @ip_id_model
				AND   cd_join_type   = 'FULL JOIN'
				AND   id_model       = @ip_id_model
				AND   id_transformation_part IN (SELECT id_transformation_part 
				                                 FROM dta.transformation_part 
																				 WHERE meta_is_active = 1 
																				 AND   id_model       = @ip_id_model 
																				 AND   id_dataset     = @ip_id_dataset);

				SELECT @is_union_join_used = CASE WHEN (COUNT(*)>1) THEN 1 ELSE 0 END
				FROM dta.transformation_part
				WHERE meta_is_active = 1
				AND   id_model   = @ip_id_model
				AND   id_dataset = @ip_id_dataset;
				
				SET @tx_sql_main_where_statement = CASE 
					WHEN @is_full_join_used = 1 OR @is_union_join_used = 1 
					THEN 'WHERE ([main].[meta_dt_valid_from] ' + @tx_sql_between + ')'
					+@nl+'   OR ([main].[meta_dt_valid_till] ' + @tx_sql_between + ')'
					ELSE ''
				END;


			END				
			IF (1=1 /* Extract "Parts" for the "Transformations". */) BEGIN

				DROP TABLE IF EXISTS #transformation_part; SELECT 
					id_transformation_part,
					ni_transformation_part,
					CASE /*  AS cd_union_type */

					  WHEN ni_transformation_part > 1 
					  AND  UPPER(@tx_source_query) LIKE '%UNION%ALL%' 
					  THEN 'UNION ALL '
						
						WHEN ni_transformation_part > 1 
					  AND  UPPER(@tx_source_query) LIKE '%UNION%' 
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
				AND   id_model   = @ip_id_model
				AND   id_dataset = @ip_id_dataset
				ORDER By ni_transformation_part;
				IF (@ip_is_debugging=1) BEGIN SELECT * FROM #transformation_part; END;

			END
			IF (1=1 /* Extract "Datasets" for the "Transformations". */) BEGIN
				DROP TABLE IF EXISTS #transformation_dataset; SELECT 
					tds.id_transformation_part,
					tds.id_transformation_dataset,
					tds.ni_transformation_dataset,
					tds.cd_alias, tds.cd_join_type,
					CASE WHEN @is_full_join_used  = 0 
					     AND  @is_union_join_used = 0 
							 AND  tds.cd_join_type    = 'FROM' 
						    THEN '  FROM (' /* Convert "FROM@is_union_join_used"-dataset into "subquery" that is filter on BK that have "change" that will "poisiblily" effect the result of the "Transformation". */
								+@nl+'    SELECT * FROM ['+dst.nm_target_schema+'].['+dst.nm_target_table+'] AS ['+tds.cd_alias+'] WHERE ['+tds.cd_alias+'].[meta_ch_bk] IN (' 
								+@nl+'      SELECT [meta_ch_bk] FROM ['+dst.nm_target_schema+'].['+dst.nm_target_table+']'
								+@nl+'      WHERE ([meta_dt_valid_from] '+@tx_sql_between+')'
								+@nl+'         OR ([meta_dt_valid_till] '+@tx_sql_between+')'
								+@nl+'  ) AS ['+tds.cd_alias+']'
								ELSE '  ' + tds.cd_join_type+' ['+dst.nm_target_schema+'].['+dst.nm_target_table+'] AS [' + tds.cd_alias + ']' + IIF(LEN(ISNULL(tds.tx_join_criteria,'-')) > 1, ' ON ' + REPLACE(ISNULL(tds.tx_join_criteria, ' '), '''', '"'), '')
					END AS tx_sql_for_replace_from_dataset
				INTO #transformation_dataset 
				FROM dta.transformation_dataset AS tds
				JOIN dta.dataset AS dst 
				ON  dst.id_model   = tds.id_source_model
				AND dst.id_dataset = tds.id_dataset 
				AND dst.meta_is_active = 1 
				AND tds.meta_is_active = 1 
        AND tds.id_model = @ip_id_model
				AND tds.id_transformation_part IN (SELECT id_transformation_part FROM #transformation_part);
				IF (@ip_is_debugging=1) BEGIN SELECT * FROM #transformation_dataset; END;
			END
				
			/* Build SQL Statement for "main" */
			SET @qry  = @emp + 'SELECT';
			SET @qry += @nwl + '  ' + REPLACE(@att, @nwl, @tb1);
			SET @qry += @emp +   '[main].[meta_dt_valid_from] AS [meta_dt_valid_from],';
			SET @qry += @nwl + '  [main].[meta_dt_valid_till] AS [meta_dt_valid_till],';
			SET @qry += @nwl + '  CONVERT(BIT, IIF([main].[meta_dt_valid_till] >= CONVERT(DATETIME, "9999-12-31"),1,0)) AS [meta_is_active],';
			SET @qry += @nwl + '  CONVERT(CHAR(32), HASHBYTES("MD5", ' + @rwh + ', 2) AS [meta_ch_rh]';
			SET @qry += @nwl + '  CONVERT(CHAR(32), HASHBYTES("MD5", ' + @bks + ', 2) AS [meta_ch_bk]';
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
					IF (@ip_is_debugging=1) BEGIN 
						select * from #transformation_dataset WHERE id_transformation_part = @id_transformation_part;
						PRINT(CONCAT(' @id_transformation_dataset : ', @id_transformation_dataset)); 
					END;


					/* Build SQL Statement of "Part" for "FROM/JON"-clause. */
					SET @qry += @nwl + @tx_sql_for_replace_from_dataset;

				END /* WHILE ((SELECT COUNT(*) FROM #transformation_dataset WHERE @id_transformation_part = @id_transformation_part)>0) */

				/* Build SQL Statement of "Part" for "WHERE/GROUP BY"-clause. */
				SET @qry += @tb1 + REPLACE(@tx_sql_where_and_or_group_by, @nwl, @tb1);

			END /* WHILE ((SELECT COUNT(*) FROM #transformation_part)>0) */

			/* finish up the "main"-subquery part. */
			SET @qry += @nwl + ') AS [main]';

			IF (@is_full_join_used = 1 OR @is_union_join_used = 1 /* then the "FROM"-dataset can NOT be filter on BK`s, thus the whole "main"-resultset must be filter afterwards. */) BEGIN
				SET @qry += IIF(LEN(@tx_sql_main_where_statement)!=0, @nwl + @tx_sql_main_where_statement, @emp);
			END

		END
		
		/* Replace the "double"-qouts for a "double-double"-quots. This is needed, because the @tx_source_query is to be passed into the "return"-resultset as a string. */
		SET @tx_source_query = REPLACE(@qry, '"', '""');
		IF (@ip_is_debugging = 1) BEGIN PRINT('@sql : ' + @qry); END

	END

	/* Reset @sql. */
	SET @sql = 'SELECT ';

	/* Build SQL Statement to "Extract" parameters for the "Ingestion". */
	WHILE ((SELECT COUNT(*) FROM #ptr) > 0) BEGIN
			
		/* Fetch next @nm_parameter and @tx_parameter_value. */
		SELECT @nm_parameter       = ptr.nm_parameter,
			     @tx_parameter_value = ptr.tx_parameter_value,
			     @ni_parameter_value = ptr.ni_parameter_value
		FROM (SELECT TOP 1 * FROM (SELECT TOP 1000 * FROM #ptr ORDER BY ni_parameter_value ASC) AS ord) AS ptr;
			
		/* Drop record from "temp"-table. */
		DELETE FROM #ptr WHERE nm_parameter = @nm_parameter;

		/* Add @nm_parameter + @tx_parameter_value to the "query"-part. */       
		SET @sql += '"<tx_parameter_value>" AS [<nm_parameter>],' + @nwl + '       ';
		SET @sql  = REPLACE(@sql, '<tx_parameter_value>', @tx_parameter_value); 
		SET @sql  = REPLACE(@sql, '<nm_parameter>',       @nm_parameter); 
						
	END
	IF (@ip_is_debugging = 1) BEGIN PRINT('@sql : ' + @sql); END

	IF ( @is_sql_source = 0 /* If NOT a SQL-source data needs to be loaded into "Landing"-table. */) BEGIN
		SET @sql += '"tsl_' + @nm_target_schema + '" AS [nm_tsl_schema],'    + @nwl + '       ';
		SET @sql += '"tsl_' + @nm_target_table  + '" AS [nm_tsl_table],'     + @nwl + '       ';
	END

	IF (1=1 /* "Save" SQL Statement to "@sql_rst_parameters". replacing the "double" qouts for a single one. */) BEGIN
		SET @sql += '"tsa_' + @nm_target_schema + '" AS [nm_tsa_schema],'    + @nwl + '       ';
		SET @sql += '"tsa_' + @nm_target_table  + '" AS [nm_tsa_table],'     + @nwl + '       ';
		SET @sql += '"' +     @nm_target_schema + '" AS [nm_target_schema],' + @nwl + '       ';
		SET @sql += '"' +     @nm_target_table  + '" AS [nm_target_table],'  + @nwl + '       ';
		SET @sql += '"' +     @tx_source_query  + '" AS [tx_source_query],'  + @nwl + '       ';

		SET @sql += '[run].[dt_previous_stand]' +  ' AS [dt_previous_stand],' + @nwl + '       ';
		SET @sql += '[run].[dt_current_stand]'  +  ' AS [dt_current_stand],'  + @nwl + '       ';
		SET @sql += '[run].[ni_previous_epoch]' +  ' AS [ni_previous_epoch],' + @nwl + '       ';
		SET @sql += '[run].[ni_current_epoch]'  +  ' AS [ni_current_epoch]'   + @nwl + '       ';
	
		SET @sql += @nwl + 'FROM [rdp].[run] AS [run]'
		SET @sql += @nwl + 'WHERE [run].[id_run] = rdp.get_id_run("' + @ip_id_dataset + '")'

		SET @sql = REPLACE(@sql, '<newline>', @nwl);
		SET @sql = REPLACE(@sql, '<@dt_previous_stand>', ISNULL(@dt_previous_stand, 'n/a'));
		SET @sql = REPLACE(@sql, '<@dt_current_stand>',  ISNULL(@dt_current_stand,  'n/a'));
		SET @sql = REPLACE(@sql, '<@ni_previous_epoch>', ISNULL(@ni_previous_epoch, 'n/a'));
		SET @sql = REPLACE(@sql, '<@ni_current_epoch>',  ISNULL(@ni_current_epoch,  'n/a'));
	
		SET @sql_rst_parameters = REPLACE(@sql, '"', @sqt);  
		
		IF (@ip_is_debugging = 1) BEGIN
			PRINT(CONCAT(' @ip_id_dataset                 : "', ISNULL(@ip_id_dataset,    'n/a'), '"'));
			PRINT(CONCAT(' @nm_target_schema              : "', ISNULL(@nm_target_schema, 'n/a'), '"'));
			PRINT(CONCAT(' @nm_target_table               : "', ISNULL(@nm_target_table,  'n/a'), '"'));
			PRINT(CONCAT(' @tx_source_query               : "', ISNULL(@tx_source_query,  'n/a'), '"'));
			PRINT(CONCAT(' @dt_previous_stand             : "', ISNULL(@dt_previous_stand,'n/a'), '"'));
			PRINT(CONCAT(' @dt_current_stand              : "', ISNULL(@dt_current_stand, 'n/a'), '"'));
		  PRINT(CONCAT(' @ni_previous_epoch             : "', ISNULL(@ni_previous_epoch,'n/a'), '"'));
			PRINT(CONCAT(' @ni_current_epoch              : "', ISNULL(@ni_current_epoch, 'n/a'), '"'));
			PRINT(CONCAT(' @is_full_join_used             : "', @is_full_join_used ,              '"')); 
			PRINT(CONCAT(' @is_union_join_used            : "', @is_union_join_used,              '"')); 
			PRINT(CONCAT(' @is_ingestion                  : "', @is_ingestion,                    '"')); 
			PRINT(CONCAT(' @nm_processing_type            : "', @nm_processing_type,              '"')); 
			PRINT(CONCAT(' @tx_sql_for_meta_dt_valid_from : "', @tx_sql_for_meta_dt_valid_from,   '"')); 
			PRINT(CONCAT(' @tx_sql_for_meta_dt_valid_till : "', @tx_sql_for_meta_dt_valid_till,   '"')); 
		END
		
		SET @message = '/* Drop table `rdp.dst_' + @ip_id_dataset + '` if already exits. */';
    SET @sql = 'DROP TABLE IF EXISTS rdp.dst_' + @ip_id_dataset + ''
		EXEC gnc_commen.show_and_execute_sql @message, @sql, @ip_is_debugging, @ip_is_testing;

		SET @message = '/* create table `rdp.dst_' + @ip_id_dataset + '`. */';
    SET @sql = REPLACE(@sql_rst_parameters, 'FROM', 'INTO rdp.dst_' + @ip_id_dataset + ' FROM');
		EXEC gnc_commen.show_and_execute_sql @message, @sql, @ip_is_debugging, @ip_is_testing;
	
	END
		
	IF (@is_ingestion = 1 /* for "Ingestion" the "Run"-info needs to be returned as "output". */) BEGIN
		
		SET @message = '/* return recordset of table `rdp.dst_' + @ip_id_dataset + '`. */';
    SET @sql = 'SELECT * FROM rdp.dst_' + @ip_id_dataset + '';
		EXEC gnc_commen.show_and_execute_sql @message, @sql, @ip_is_debugging, @ip_is_testing;

	END

	RETURN 0

END
GO