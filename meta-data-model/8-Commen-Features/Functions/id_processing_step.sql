CREATE FUNCTION gnc_commen.id_processing_step (@ip_id_model CHAR(32), @ip_fn_processing_step NVARCHAR(128) ) RETURNS CHAR(32) AS BEGIN

  /* ----------------------------------------------------------------------- */
  /* This function will return "id_processing_step" based on the input of    */
  /* "@ip_fn_processing_step".                                               */ 
  /* ----------------------------------------------------------------------- */
  
  RETURN (
    SELECT id_processing_step FROM srd.processing_step 
    WHERE meta_is_active     = 1 
    AND   id_model           = @ip_id_model
    AND   fn_processing_step = @ip_fn_processing_step
  );

END
GO
