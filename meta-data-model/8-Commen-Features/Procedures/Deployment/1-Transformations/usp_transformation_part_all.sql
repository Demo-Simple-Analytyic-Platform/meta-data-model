CREATE PROCEDURE deployment.usp_transformation_part_all

    /* Input Parameters */
    @ip_is_debugging     BIT = 1,
    @ip_is_testing       BIT = 0

AS DECLARE 
      
    /* Data Attributes */
    @nm_target_schema NVARCHAR(128),
    @nm_target_table  NVARCHAR(128)

BEGIN
    
  IF (1=1 /* Extract all "datasets". */) BEGIN

    DROP TABLE IF EXISTS ##dst; SELECT 
      id_dataset,
      nm_target_schema,
      nm_target_table
    INTO ##dst FROM tsa_dta.tsa_dataset AS dst 
    WHERE dst.is_ingestion = 0
    AND   ISNULL(dst.tx_source_query,'') != '';

  END

  IF (1=1 /* Cleanup op "Transformation"-part that are no longer "Transformations". */) BEGIN
    DELETE FROM tsa_dta.tsa_transformation_part;
    DELETE FROM tsa_dta.tsa_transformation_dataset;
    DELETE FROM tsa_dta.tsa_transformation_mapping;
    DELETE FROM tsa_dta.tsa_transformation_attribute;
  END;

  WHILE ((SELECT COUNT(*) FROM ##dst) > 0) BEGIN

    /* Extract "target"-schema and -table. */
    SELECT @nm_target_schema = dst.nm_target_schema,
           @nm_target_table  = dst.nm_target_table
    FROM (SELECT TOP 1 * FROM ##dst) AS dst;

	  /* Extract all "Transformation"-parts from "source"-query. */
    EXEC deployment.usp_transformation_part
      @ip_nm_target_schema = @nm_target_schema,
      @ip_nm_target_table  = @nm_target_table,
      @ip_is_debugging     = 0,
      @ip_is_testing       = 0;

    /* Remove processed "dataset". */
    DELETE FROM ##dst 
    WHERE nm_target_schema = @nm_target_schema
    AND   nm_target_table  = @nm_target_table;

  END
  
END
GO