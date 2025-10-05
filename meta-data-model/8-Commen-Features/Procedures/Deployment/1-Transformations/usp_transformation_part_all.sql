CREATE PROCEDURE deployment.usp_transformation_part_all

    /* Input Parameters */
    @ip_is_debugging     BIT = 1,
    @ip_is_testing       BIT = 0,
    @ip_is_override      BIT = 0 /* Is set to 1 to override re-build procedure for ever table. */

AS DECLARE 
      
    /* Data Attributes */
    @id_model         CHAR(32) = (SELECT id_model FROM mdm.current_model),
    @nm_target_schema NVARCHAR(128),
    @nm_target_table  NVARCHAR(128)

  DECLARE /* Get the last deployment date for the current model. */
    @meta_dt_valid_from DATETIME = (SELECT dt_deployment FROM mdm.last_deployment WHERE id_model = @id_model);

BEGIN
    
  IF (1=1 /* Extract all "datasets". */) BEGIN

    DROP TABLE IF EXISTS ##dst; SELECT 
      id_dataset,
      nm_target_schema,
      nm_target_table
    INTO ##dst FROM tsa_dta.tsa_dataset AS dst 
    WHERE dst.is_ingestion = 0
    AND   ISNULL(dst.tx_source_query,'') != ''
    --
    -- Filter on Dataset that were cahnges sinds last deployment of the model.
    AND dst.id_dataset IN (
      SELECT id_dataset FROM dta.dataset       AS flt WHERE id_model = @id_model AND CASE WHEN @ip_is_override = 1 THEN 1 WHEN meta_dt_valid_from > @meta_dt_valid_from THEN 1 ELSE 0 END = 1 UNION
      SELECT id_dataset FROM dta.attribute     AS flt WHERE id_model = @id_model AND CASE WHEN @ip_is_override = 1 THEN 1 WHEN meta_dt_valid_from > @meta_dt_valid_from THEN 1 ELSE 0 END = 1 UNION
      SELECT id_dataset FROM dta.ingestion_etl AS flt WHERE id_model = @id_model AND CASE WHEN @ip_is_override = 1 THEN 1 WHEN meta_dt_valid_from > @meta_dt_valid_from THEN 1 ELSE 0 END = 1
    );
  END

  IF (1=1 /* Cleanup op "Transformation"-part that are no longer "Transformations". */) BEGIN
    DELETE FROM tsa_dta.tsa_transformation_part;
    DELETE FROM tsa_dta.tsa_transformation_dataset;
    DELETE FROM tsa_dta.tsa_transformation_mapping;
    DELETE FROM tsa_dta.tsa_transformation_attribute;
  END;
  IF (1=1 /* Cleanup op "Transformation"-part that are no longer "Transformations". */) BEGIN
    
    INSERT INTO tsa_dta.tsa_transformation_part (id_model, id_dataset, id_transformation_part, ni_transformation_part, tx_transformation_part) 
    SELECT id_model, id_dataset, id_transformation_part, ni_transformation_part, tx_transformation_part
    FROM dta.transformation_part WHERE id_model = @id_model AND meta_is_active = 1;
    
    INSERT INTO tsa_dta.tsa_transformation_dataset (id_model, id_transformation_part, id_transformation_dataset, ni_transformation_dataset, cd_join_type, id_source_model, id_dataset, cd_alias, tx_join_criteria)
    SELECT id_model, id_transformation_part, id_transformation_dataset, ni_transformation_dataset, cd_join_type, id_source_model, id_dataset, cd_alias, tx_join_criteria
    FROM dta.transformation_dataset WHERE id_model = @id_model AND meta_is_active = 1;

    INSERT INTO tsa_dta.tsa_transformation_mapping (id_model, id_transformation_mapping, id_transformation_part, id_attribute, is_in_group_by, tx_transformation_mapping)
    SELECT id_model, id_transformation_mapping, id_transformation_part, id_attribute, is_in_group_by, tx_transformation_mapping
    FROM dta.transformation_mapping WHERE id_model = @id_model AND meta_is_active = 1;

    INSERT INTO tsa_dta.tsa_transformation_attribute (id_model, id_transformation_attribute, id_transformation_mapping, id_source_model, id_attribute)
    SELECT id_model, id_transformation_attribute, id_transformation_mapping, id_source_model, id_attribute
    FROM dta.transformation_attribute WHERE id_model = @id_model AND meta_is_active = 1;

  END;
  IF (1=1 /* Remove all "Transformation"-parts/datasets/mappings/attributes that are no longer related to active dataset. */) BEGIN
    DELETE FROM tsa_dta.tsa_transformation_part      WHERE id_model = @id_model AND id_dataset                NOT IN (SELECT id_dataset FROM ##dst); /* Remove all "Transformation"-parts that will be updated. */
    DELETE FROM tsa_dta.tsa_transformation_part      WHERE id_model = @id_model AND id_dataset                NOT IN (SELECT id_dataset                FROM tsa_dta.tsa_dataset                WHERE id_model = @id_model);
    DELETE FROM tsa_dta.tsa_transformation_dataset   WHERE id_model = @id_model AND id_transformation_part    NOT IN (SELECT id_transformation_part    FROM tsa_dta.tsa_transformation_part    WHERE id_model = @id_model);
    DELETE FROM tsa_dta.tsa_transformation_mapping   WHERE id_model = @id_model AND id_transformation_part    NOT IN (SELECT id_transformation_part    FROM tsa_dta.tsa_transformation_part    WHERE id_model = @id_model);
    DELETE FROM tsa_dta.tsa_transformation_attribute WHERE id_model = @id_model AND id_transformation_mapping NOT IN (SELECT id_transformation_mapping FROM tsa_dta.tsa_transformation_mapping WHERE id_model = @id_model);
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