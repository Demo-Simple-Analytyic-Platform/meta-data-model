CREATE PROCEDURE deployment.usp_transformation_dataset_all

    /* Input Parameters */
    @ip_is_debugging     BIT = 1,
    @ip_is_testing       BIT = 0

AS DECLARE 
      
    /* Data Attributes */
    @id_model               CHAR(32) = (SELECT id_model FROM mdm.current_model),
    @id_transformation_part CHAR(32),
    @tx_transformation_part NVARCHAR(MAX);

  DECLARE /* Get the last deployment date for the current model. */
    @meta_dt_valid_from DATETIME = (SELECT dt_deployment FROM mdm.last_deployment WHERE id_model = @id_model);

BEGIN
    
  IF (1=1 /* Extract all "datasets". */) BEGIN

    DROP TABLE IF EXISTS ##prt; SELECT 
      prt.id_transformation_part,
      prt.tx_transformation_part
    INTO ##prt FROM tsa_dta.tsa_transformation_part AS prt
    --
    -- Filter on Dataset that were cahnges sinds last deployment of the model.
    WHERE prt.id_transformation_part IN (SELECT id_transformation_part FROM dta.transformation_part AS flt 
                                         WHERE  id_model           = @id_model 
                                         AND    meta_dt_valid_from > @meta_dt_valid_from);

  END

  WHILE ((SELECT COUNT(*) FROM ##prt) > 0) BEGIN

    /* Extract "target"-schema and -table. */
    SELECT @id_transformation_part = prt.id_transformation_part,
           @tx_transformation_part = prt.tx_transformation_part
    FROM (SELECT TOP 1 * FROM ##prt) AS prt;

	  /* Extract all "Transformation"-parts from "source"-query. */
    IF (@ip_is_debugging = 1) BEGIN
      PRINT('--- Debugging info for "deployment.usp_transformation_dataset" ------------');
      PRINT('@id_transformation_part : ' + @id_transformation_part);
      PRINT('@tx_transformation_part : ' + @tx_transformation_part);
      PRINT('---------------------------------------------------------------------------');
      PRINT('');
    END

    EXEC deployment.usp_transformation_dataset

      @ip_id_transformation_part = @id_transformation_part,
      @ip_tx_transformation_part = @tx_transformation_part,
      @ip_is_debugging           = @ip_is_debugging,
      @ip_is_testing             = @ip_is_testing;

    /* Remove processed "dataset". */
    DELETE FROM ##prt
    WHERE id_transformation_part = @id_transformation_part;

  END
  
END
GO

