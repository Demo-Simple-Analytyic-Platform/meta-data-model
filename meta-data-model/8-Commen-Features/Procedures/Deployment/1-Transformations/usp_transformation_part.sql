CREATE PROCEDURE deployment.usp_transformation_part
    
    /* Input Parameters */
    @ip_nm_target_schema NVARCHAR(128),
    @ip_nm_target_table  NVARCHAR(128),

    /* Input Parameters */
    @ip_is_debugging     BIT = 1,
    @ip_is_testing       BIT = 0

AS BEGIN

  SET NOCOUNT ON;

  DECLARE 

      /* Current Model */
      @id_model CHAR(32) = (SELECT id_model FROM mdm.current_model),
      
      /* Data Attributes */
      @id_dataset             CHAR(32),
      @id_transformation_part CHAR(32),
      @ni_transformation_part INT,
      @tx_transformation_part NVARCHAR(MAX),
  
      /* Local Variables for Extraction of "Transformation-Parts" */
      @ni_position_start      INT = 1,
      @ni_position_union      INT = 1,
      @ni_union_used          INT = 1,
        
      /* Local Variabels for "Dataset"-query. */
      @tx_source_query NVARCHAR(MAX),       
  
      /* Local Variables for "Error"-message */
      @tx_error_message NVARCHAR(MAX) = '',
      @tx_sql_execution NVARCHAR(MAX) = '',
  
      /* Helper SQL Statement for Merge */
      @now DATETIME2(7)  = GETDATE(),
      @sql NVARCHAR(MAX) = ''

  BEGIN TRY
        
    IF (1=1 /* Cleanup "Source"-query */) BEGIN

      SELECT @tx_source_query = dst.tx_source_query,
             @id_dataset      = dst.id_dataset
      FROM tsa_dta.tsa_dataset AS dst 
      WHERE dst.is_ingestion     = 0
      AND   dst.nm_target_schema = @ip_nm_target_schema 
      AND   dst.nm_target_table  = @ip_nm_target_table
      AND   LEN(dst.tx_source_query) > 10;

      /* Minify "SQL"-source query. */
      SET @tx_source_query = REPLACE(@tx_source_query, '<newline>', ' ');
      SET @tx_source_query = gnc_commen.svf_minify(@tx_source_query);

			IF (@ip_is_debugging = 1) BEGIN
				PRINT('')
				PRINT('@nm_target_schema : "'+ @ip_nm_target_schema + '"')
				PRINT('@nm_target_table  : "'+ @ip_nm_target_table  + '"') 
				PRINT('@tx_source_query  : '); EXEC gnc_commen.to_concol_window @tx_source_query;
			END

    END
  
		IF (1=1 /* Check how many "Transformation-Part(s)" there are. */) BEGIN		  
      
      SELECT @ni_union_used = COUNT(*) + 1 FROM ( 
        SELECT tx_sql_statement = TRIM(value), ni_dummy = 1 
        FROM STRING_SPLIT(@tx_source_query, ' ') 
        WHERE UPPER(value) = 'UNION' 
      ) AS s;
      
      IF (@ip_is_debugging = 1) BEGIN PRINT('@ni_union_used : ' + FORMAT(@ni_union_used, 'N0')); END

    END

    SET @ni_transformation_part = 0; WHILE (@ni_transformation_part < (@ni_union_used)) BEGIN

	    IF (1=1 /* Determine the "Start"- and "Union"- positions. */) BEGIN
        SET @ni_position_start = CHARINDEX('SELECT', @tx_source_query, @ni_position_union);
	      SET @ni_position_union = CHARINDEX('UNION',  @tx_source_query, @ni_position_start);
	      SET @ni_position_union = IIF(@ni_position_union=0, LEN(@tx_source_query)+1, @ni_position_union);
      END

	    IF (1=1 /* Extract the "Transformation"-part from the full query. */) BEGIN
	      SET @ni_transformation_part += 1;
	      SET @id_transformation_part  = LOWER(CONVERT(CHAR(32),HASHBYTES('MD5',CONCAT(CONVERT(NVARCHAR(MAX),''), 
                                       '|', @id_dataset,
                                       '|', @ni_transformation_part, 
                                       '|' )), 2));
        SET @tx_transformation_part  = TRIM(SUBSTRING(@tx_source_query, @ni_position_start, (@ni_position_union - @ni_position_start)))
      END

	    IF (@ip_is_debugging = 1 /* Show if in debugginh mode. */) BEGIN
	      PRINT('@ni_position_start      : ' + FORMAT(@ni_position_start, 'N0'));
	      PRINT('@ni_position_union      : ' + FORMAT(@ni_position_union, 'N0'));
	      PRINT('@id_transformation_part : "'       + @id_transformation_part + '"');
        PRINT('@ni_transformation_part : ' + FORMAT(@ni_transformation_part, 'N0'));
        PRINT('@tx_transformation_part : "'       + @tx_transformation_part + '"');
      END

      IF (@ip_is_testing = 0 /* If NOT in Testing-mode */) BEGIN
        INSERT INTO tsa_dta.tsa_transformation_part 
        ( id_model,  id_dataset, id_transformation_part, ni_transformation_part, tx_transformation_part) VALUES
        (@id_model, @id_dataset,@id_transformation_part,@ni_transformation_part,@tx_transformation_part);
      END

    END /* WHILE */
  
  END TRY
  BEGIN CATCH

    /* If an error occurs, show the error message. */
    SET @tx_error_message = '--- Error in usp_transformation_part: ---------------------------------------'
               + CHAR(10) + '-- Message  : ' + ERROR_MESSAGE()
               + CHAR(10) + '-- Line     : ' + CONVERT(NVARCHAR(10), ERROR_LINE())
               + CHAR(10) + '-- State    : ' + CONVERT(NVARCHAR(10), ERROR_STATE()) 
               + CHAR(10) + '-- Severity : ' + CONVERT(NVARCHAR(10), ERROR_SEVERITY());
    SET @tx_sql_execution = 'EXEC deployment.usp_transformation_part '
               + CHAR(10) + '  ip_nm_target_schema = ''' + @ip_nm_target_schema + ''','
               + CHAR(10) + '  @ip_nm_target_table = ''' + @ip_nm_target_table  + ''','
               + CHAR(10) + '  @ip_is_debugging    = 1,'
               + CHAR(10) + '  @ip_is_testing      = 0;';
    PRINT('')
    PRINT(@tx_error_message);
    PRINT(@tx_sql_execution);
    PRINT('');
   
  END CATCH
END
GO