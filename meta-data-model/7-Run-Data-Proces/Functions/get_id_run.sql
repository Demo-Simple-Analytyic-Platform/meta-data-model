CREATE FUNCTION rdp.get_id_run (
  
  /* Input Parameters */
  @ip_id_model   CHAR(32),
  @ip_id_dataset CHAR(32)

) RETURNS CHAR(32) AS BEGIN 

RETURN (
  SELECT id_run FROM rdp.run 
  WHERE id_model   = @ip_id_model
  AND   id_dataset = @ip_id_dataset 
  AND   ISNULL(dt_run_finished, CONVERT(DATETIME, '9999-12-31')) >= CONVERT(DATETIME, '9999-12-31')
)
END
GO
