CREATE FUNCTION gnc_commen.id_processing_status (@ip_id_model CHAR(32), @ip_fn_processing_status NVARCHAR(128) ) RETURNS CHAR(32) AS BEGIN

  /* ----------------------------------------------------------------------- */
  /* This function will return "id_processing_status" based on the input of  */
  /* "@ip_fn_processing_status".                                             */ 
  /* ----------------------------------------------------------------------- */
  
  RETURN (
    SELECT id_processing_status FROM srd.processing_status 
    WHERE meta_is_active       = 1 
    AND   id_model             = @ip_id_model
    AND   fn_processing_status = @ip_fn_processing_status
  );

END
GO
