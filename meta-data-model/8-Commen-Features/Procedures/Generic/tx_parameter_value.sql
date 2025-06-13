CREATE FUNCTION gnc_commen.tx_parameter_value (@ip_id_model CHAR(32), @ip_id_dataset NVARCHAR(128), @ip_nm_parameter NVARCHAR(128)) RETURNS NVARCHAR(MAX) AS BEGIN RETURN (
  
  /* ----------------------------------------------------------------------- */
  /* This function will return the value of a parameter registered to a      */
  /* (Ingestion) "dataset". Based on the @ip_id_dataset and @ip_nm_parameter */ 
  /* ----------------------------------------------------------------------- */
  
  SELECT tx_parameter_value
  FROM dta.parameter_value 
  WHERE meta_is_active = 1 
  AND   id_model       = @ip_id_model
  AND   id_dataset     = @ip_id_dataset
  AND   id_parameter   = (
    SELECT id_parameter
    FROM srd.parameter
    WHERE meta_is_active = 1
    AND   nm_parameter   = @ip_nm_parameter
    and   id_model       = @ip_id_model 
  ));
END
GO
