CREATE FUNCTION gnc_commen.tsa_id_dq_result_status (

  /* Input Parameters */
  @ip_id_model            CHAR(32), 
  @ip_fn_dq_result_status NVARCHAR(128)

) RETURNS CHAR(32) AS BEGIN
  
  /* ----------------------------------------------------------------------- */
  /* This function will return "id_dq_result_status" based on the input of   */
  /* "@ip_fn_dq_result_status".                                              */ 
  /* ----------------------------------------------------------------------- */
  
  RETURN (
    SELECT id_dq_result_status FROM tsa_srd.tsa_dq_result_status 
    WHERE 1=1 --meta_is_active      = 1 
    AND   id_model            = @ip_id_model 
    AND   fn_dq_result_status = @ip_fn_dq_result_status
  );

END