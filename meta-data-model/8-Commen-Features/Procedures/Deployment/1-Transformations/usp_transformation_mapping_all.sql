CREATE PROCEDURE deployment.usp_transformation_mapping_all

    /* Input Parameters */
    @ip_is_debugging     BIT = 1,
    @ip_is_testing       BIT = 0

AS DECLARE 
      
    /* Data Attributes */
    @id_transformation_part CHAR(32),
    @tx_transformation_part NVARCHAR(MAX),

    /* Helper for Debugging */
    @sql NVARCHAR(MAX) = '',
    @emp NVARCHAR(1)   = '',
    @nwl NVARCHAR(1)   = CHAR(10)

BEGIN
    
  IF (1=1 /* Extract all "datasets". */) BEGIN

    DROP TABLE IF EXISTS ##prt; SELECT 
      prt.id_transformation_part,
      prt.tx_transformation_part
    INTO ##prt FROM tsa_dta.tsa_transformation_part AS prt;

  END

  WHILE ((SELECT COUNT(*) FROM ##prt) > 0) BEGIN

    /* Extract "target"-schema and -table. */
    SELECT @id_transformation_part = prt.id_transformation_part,
           @tx_transformation_part = prt.tx_transformation_part
    FROM (SELECT TOP 1 * FROM ##prt) AS prt;

    IF (@ip_is_debugging = 1) BEGIN
      SET @sql  = @emp + 'DECLARE'  
      SET @sql += @nwl + '  @id_transformation_part CHAR(32)      = "' + @id_transformation_part + '",'
      SET @sql += @nwl + '  @tx_transformation_part NVARCHAR(MAX) = "' + REPLACE(@tx_transformation_part,'''','""') + '";'
      SET @sql += @nwl + 'BEGIN' 
      SET @sql += @nwl + '	EXEC ##usp_transformation_mapping'
      SET @sql += @nwl + '	  @ip_id_transformation_part = @id_transformation_part,'
      SET @sql += @nwl + '    @ip_tx_transformation_part = @tx_transformation_part,'
      SET @sql += @nwl + '	  @ip_is_debugging           = 1;'
      SET @sql += @nwl + 'END'
      SET @sql = REPLACE(@sql, '"', '''');
      EXEC gnc_commen.to_concol_window @sql;
    END

	  /* Extract all "Transformation"-parts from "source"-query. */
    EXEC deployment.usp_transformation_mapping
      @ip_id_transformation_part = @id_transformation_part,
      @ip_tx_transformation_part = @tx_transformation_part,
      @ip_is_debugging           = @ip_is_debugging,
      @ip_is_testing             = @ip_is_testing;

    /* Remove processed "dataset". */
    DELETE FROM ##prt WHERE id_transformation_part = @id_transformation_part;

  END
  
END
GO

