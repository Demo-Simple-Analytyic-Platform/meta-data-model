CREATE PROCEDURE [deployment].[build_html_file_dataset_all]

    /* Input Parameters */
    @ip_is_debugging     BIT = 0,
    @ip_is_testing       BIT = 0

AS DECLARE 
      
    /* Data Attributes */
    @id_dataset CHAR(32),
    @id_model   CHAR(32);

BEGIN
    
  IF (1=1 /* Extract all "datasets". */) BEGIN

    DROP TABLE IF EXISTS ##htm; SELECT dst.id_dataset, dst.id_model
    INTO ##htm FROM tsa_dta.tsa_dataset AS dst
    WHERE NOT nm_target_schema IN ('dq_result', 'dq_totals', 'dta_dq_aggregates', 'dqm');

  END

  WHILE ((SELECT COUNT(*) FROM ##htm) > 0) BEGIN
    
    /* Fetch Next "dataset" and remove from temp-table.. */
    SELECT @id_dataset = id_dataset, @id_model = id_model
    FROM (SELECT TOP 1 * FROM ##htm) AS dst;
    DELETE FROM ##htm WHERE id_dataset = @id_dataset;

	  /* Extract all "Transformation"-parts from "source"-query. */
    EXEC [mdm].[usp_build_html_file_dataset]
      @ip_id_model     = @id_model,
      @ip_id_dataset   = @id_dataset,
      @ip_is_debugging = @ip_is_debugging;

  END
  
END
GO
