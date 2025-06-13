CREATE PROCEDURE deployment.usp_transformation_mapping
    
    /* Input Parameters */
    @ip_id_transformation_part CHAR(32),
    @ip_tx_transformation_part NVARCHAR(MAX),

    /* Input Parameters */
    @ip_is_debugging BIT = 0,
    @ip_is_testing   BIT = 0

AS DECLARE /* Local Variables */

  /* Current Model */
  @id_model CHAR(32) = (SELECT id_model FROM mdm.current_model),

  @tx_sql_statement   NVARCHAR(MAX) = '',
  @tx_sql_group_by    NVARCHAR(MAX) = '',
  @ni_position_begin  INT = 0,
  @ni_position_end    INT = 0,
  @ni_position_length INT = 0,
	@id_dataset CHAR(32) = (SELECT DISTINCT id_dataset FROM tsa_dta.tsa_transformation_part WHERE id_transformation_part = @ip_id_transformation_part)

BEGIN  

  IF (1=1 /* Extraction of "SELECT"-clauses of "Transformation"-part. */) BEGIN
		
	  /* Minify "Query" and "escape"  the "<newline>". */
	  SET @tx_sql_statement = gnc_commen.svf_minify(replace(@ip_tx_transformation_part, '<newline>', CHAR(10)));

	  /* Find " Beginning" of the "FROM/JOIN"-clause. */ 
	  SET @ni_position_begin = CHARINDEX('SELECT', UPPER(@tx_sql_statement), 1);

	  /* Find the "End" of the "FROM/JOIN"-clause. */ 
	  SET @ni_position_end = CHARINDEX('FROM', UPPER(@tx_sql_statement), 1);
		
	  /* If both the "Begin" and "End" have been found, determine the "Length". */
	  SET @ni_position_length = IIF(@ni_position_end = 0, LEN(@tx_sql_statement), @ni_position_end) - @ni_position_begin;

	  /* Extract only the "FROM/JOIN"-clause of the "Query". */
	  SET @tx_sql_statement = TRIM(SUBSTRING(@tx_sql_statement, @ni_position_begin, @ni_position_length));

	  /* Remove "SELECT" from the "SQL"-statements. */
	  SET @tx_sql_statement = SUBSTRING(@tx_sql_statement, 8, LEN(@tx_sql_statement)-7);

	  /* Show extracted "FROM/JOIN"-clause. */
	  IF (@ip_is_debugging = 1 ) BEGIN EXEC gnc_commen.to_concol_window @tx_sql_statement; END

  END;

  IF (CHARINDEX('GROUP BY', @ip_tx_transformation_part, 1) > 0 /* Extraction of "GROUP BY"-clauses of "Transformation"-part. */) BEGIN
		
	  /* Minify "Query" and "escape"  the "<newline>". */
	  SET @tx_sql_group_by = gnc_commen.svf_minify(replace(@ip_tx_transformation_part, '<newline>', CHAR(10)));

	  /* Find " Beginning" of the "FROM/JOIN"-clause. */ 
	  SET @ni_position_begin = CHARINDEX('GROUP BY', UPPER(@tx_sql_group_by), 1);

	  /* Find the "End" of the "FROM/JOIN"-clause. */ 
	  SET @ni_position_end = CHARINDEX('HAVING', UPPER(@tx_sql_group_by), 1);
		
	  /* If both the "Begin" and "End" have been found, determine the "Length". */
	  SET @ni_position_length = IIF(@ni_position_end = 0, LEN(@tx_sql_group_by), @ni_position_end) - @ni_position_begin;

	  /* Extract only the "GROUP BY"-clause of the "Query". */
	  SET @tx_sql_group_by = TRIM(SUBSTRING(@tx_sql_group_by, @ni_position_begin, @ni_position_length));

	  /* Remove "GROUP BY" from the "SQL"-statements. */
	  SET @tx_sql_group_by = SUBSTRING(@tx_sql_group_by, 8, LEN(@tx_sql_group_by)-7);

	  /* Show extracted "FROM/JOIN"-clause. */
	  IF (@ip_is_debugging = 1 ) BEGIN EXEC gnc_commen.to_concol_window @tx_sql_group_by; END

  END;

  IF (1=1 /* "Temp"-table: tx -> Convert "SQL"-statement to individual "words". */) BEGIN
	  DROP TABLE IF EXISTS #tx; SELECT 
	  TRIM(VALUE) AS tx_sql, 1 AS ni_dummy 
	  INTO #tx FROM STRING_SPLIT(@tx_sql_statement, ',');
	  IF (@ip_is_debugging = 1) BEGIN SELECT * FROM #tx; END;
  END

  IF (1=1 /* "Temp"-table: at -> list expacted Attributes(s) */) BEGIN
    DROP TABLE IF EXISTS #at; SELECT 
      att.id_attribute,
	    att.ni_ordering,
	    att.nm_target_column,
	    ' AS [' + att.nm_target_column + ']' AS tx_to_be_searched_1,
	    ' AS '  + att.nm_target_column +  '' AS tx_to_be_searched_2
    INTO #at FROM tsa_dta.tsa_attribute AS att 
	  WHERE att.id_dataset = @id_dataset
		AND   SUBSTRING(att.nm_target_column,1,4) != 'meta' 
	  IF (@ip_is_debugging = 1) BEGIN SELECT * FROM #at; END;
  END

  IF (1=1 /* "Temp"-table: md -> Find de postions of "alias" of expected "target"-columns */) BEGIN
    DROP TABLE IF EXISTS #md; SELECT 
		  att.id_attribute,
		  att.ni_ordering,
		  att.nm_target_column,
      CHARINDEX(att.tx_to_be_searched_1, @tx_sql_statement, 1) + 
		  CHARINDEX(att.tx_to_be_searched_2, @tx_sql_statement, 1) AS ni_position_till,
		  IIF(CHARINDEX(att.tx_to_be_searched_1, @tx_sql_statement, 1)>0,LEN(att.tx_to_be_searched_1),0) +
		  IIF(CHARINDEX(att.tx_to_be_searched_2, @tx_sql_statement, 1)>0,LEN(att.tx_to_be_searched_2),0) AS ni_to_be_searched_length,
	    IIF(CHARINDEX(att.tx_to_be_searched_1, @tx_sql_statement, 1)>0, att.tx_to_be_searched_1,
		  IIF(CHARINDEX(att.tx_to_be_searched_2, @tx_sql_statement, 1)>0, att.tx_to_be_searched_2, '')) AS tx_to_be_searched,
		  1 As ni_dummy
	  INTO #md FROM #at AS att;
	  IF (@ip_is_debugging = 1) BEGIN SELECT * FROM #md ORDER BY ni_ordering ASC; END
  END

  IF (1=1 /* "Temp"-table: ls -> Last "ni_ordering" */) BEGIN
    DROP TABLE IF EXISTS #ls; SELECT 
      MAX(ni.ni_ordering) AS ni_ordering
    INTO #ls FROM #md AS ni;
	  IF (@ip_is_debugging = 1) BEGIN SELECT * FROM #ls; END
  END

  IF (1=1 /* "Temp"-table: be -> Begin and End. */) BEGIN
    DROP TABLE IF EXISTS #be; SELECT 
      
	    md.id_attribute     AS id_attribute,
	    md.ni_ordering      AS ni_ordering,
	    md.nm_target_column AS nm_target_column,
	    IIF( /*             AS ni_position_from, */
	      ISNULL(LAG(md.ni_position_till)         OVER (PARTITION BY md.ni_dummy ORDER BY md.ni_position_till), 1) = 1, 1, 
	      ISNULL(LAG(md.ni_position_till)         OVER (PARTITION BY md.ni_dummy ORDER BY md.ni_position_till), 1) + 
	      ISNULL(LAG(md.ni_to_be_searched_length) OVER (PARTITION BY md.ni_dummy ORDER BY md.ni_position_till), 1) + 2
	    ) AS ni_position_from,
	    md.ni_position_till AS ni_position_till

    INTO #be FROM #md AS md;
		IF (@ip_is_debugging = 1) BEGIN SELECT * FROM #be; END
  END

  IF (1=1 /* "Temp"-table: mp -> Mapping. */) BEGIN
    DROP TABLE IF EXISTS #tsa_transformation_mapping; SELECT 
      
			LOWER(CONVERT(CHAR(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''),'|', @ip_id_transformation_part,'|', be.id_attribute)), 2)) AS id_transformation_mapping,
      @ip_id_transformation_part  AS id_transformation_part,
      be.id_attribute             AS id_attribute,
      CASE /*                     AS is_in_group_by */
			  WHEN be.ni_position_till = 0 
			  THEN 0
			  WHEN CHARINDEX(SUBSTRING(@tx_sql_statement, be.ni_position_from, (be.ni_position_till - be.ni_position_from)),@tx_sql_group_by, 1) > 0
				THEN 1
				ELSE 0
			END AS is_in_group_by,
			CASE                     /* AS tx_transformation_mapping */
			  WHEN be.ni_position_till != 0 
			  THEN SUBSTRING(@tx_sql_statement, be.ni_position_from, (be.ni_position_till - be.ni_position_from)) 
        ELSE ''
			END AS tx_transformation_mapping,
      be.ni_ordering              AS ni_ordering,
      be.nm_target_column         AS nm_target_column,
      be.ni_position_from         AS ni_position_from,
      be.ni_position_till         AS ni_position_till
	  
    INTO #tsa_transformation_mapping FROM #be AS be;
  	IF (@ip_is_debugging = 1) BEGIN SELECT * FROM #tsa_transformation_mapping; END
  END

  IF (@ip_is_testing = 0 /* If NOT in Testing-mode */) BEGIN
    INSERT INTO tsa_dta.tsa_transformation_mapping (id_model, id_transformation_mapping, id_transformation_part, id_attribute, is_in_group_by, tx_transformation_mapping) 
		SELECT @id_model, id_transformation_mapping, id_transformation_part, id_attribute, is_in_group_by, tx_transformation_mapping
    FROM #tsa_transformation_mapping;
  END

END
GO