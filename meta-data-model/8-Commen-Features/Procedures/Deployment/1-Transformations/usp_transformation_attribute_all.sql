CREATE PROCEDURE deployment.usp_transformation_attribute_all

    /* Input Parameters */
    @ip_is_debugging     BIT = 1,
    @ip_is_testing       BIT = 0

AS DECLARE 
      
    /* Data Attributes */
    @id_model                  CHAR(32) = (SELECT id_model FROM mdm.current_model),
    @id_transformation_mapping CHAR(32);

  DECLARE /* Get the last deployment date for the current model. */
    @meta_dt_valid_from DATETIME = (SELECT dt_deployment FROM mdm.last_deployment WHERE id_model = @id_model);

BEGIN
    
  IF (1=1 /* Extract all "datasets". */) BEGIN

    DROP TABLE IF EXISTS ##map; SELECT 
      map.id_transformation_mapping
    INTO ##map FROM tsa_dta.tsa_transformation_mapping AS map
    --
    -- Filter on Dataset that were cahnges sinds last deployment of the model.
    WHERE map.id_transformation_mapping IN (SELECT id_transformation_mapping FROM dta.transformation_mapping AS flt 
                                             WHERE id_model           = @id_model 
                                             AND   meta_dt_valid_from > @meta_dt_valid_from);

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

