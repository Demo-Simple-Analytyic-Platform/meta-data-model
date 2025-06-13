CREATE PROCEDURE deployment.usp_transformation_attribute_all

    /* Input Parameters */
    @ip_is_debugging     BIT = 1,
    @ip_is_testing       BIT = 0

AS DECLARE 
      
    /* Data Attributes */
    @id_transformation_mapping CHAR(32)

BEGIN
    
  IF (1=1 /* Extract all "datasets". */) BEGIN

    DROP TABLE IF EXISTS ##map; SELECT 
      map.id_transformation_mapping
    INTO ##map FROM tsa_dta.tsa_transformation_mapping AS map
    ;

  END

  WHILE ((SELECT COUNT(*) FROM ##map) > 0) BEGIN

    /* Extract "target"-schema and -table. */
    SELECT @id_transformation_mapping = map.id_transformation_mapping
    FROM (SELECT TOP 1 * FROM ##map) AS map;

	  /* Extract all "Transformation"-parts from "source"-query. */
    EXEC deployment.usp_transformation_attribute
      @ip_id_transformation_mapping = @id_transformation_mapping,
      @ip_is_debugging              = @ip_is_debugging,
      @ip_is_testing                = @ip_is_testing;

    /* Remove processed "dataset". */
    DELETE FROM ##map
    WHERE id_transformation_mapping = @id_transformation_mapping;

  END
  
END
GO

