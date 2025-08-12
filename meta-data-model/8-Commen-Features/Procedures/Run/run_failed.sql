CREATE PROCEDURE rdp.run_failed
  
  /* Input Parameters */
  @ip_id_model   CHAR(32),
  @ip_id_dataset CHAR(32)

AS DECLARE

  @tx_message NVARCHAR(MAX) = '';

BEGIN

	/* Build Text Message for Error info. */
	SET @tx_message += '=== Error Message ================================================'     + CHAR(10)
	SET @tx_message += 'Procedure : ' + CONVERT(NVARCHAR(255), ISNULL(ERROR_PROCEDURE(),'n/a'))	+ CHAR(10)
	SET @tx_message += 'Line      : ' + CONVERT(NVARCHAR(255), ERROR_LINE())				            + CHAR(10)
	SET @tx_message += 'Numer     : ' + CONVERT(NVARCHAR(255), ERROR_NUMBER())			            + CHAR(10)
	SET @tx_message += 'Message   : ' + CONVERT(NVARCHAR(255), ERROR_MESSAGE())			            + CHAR(10)
	SET @tx_message += 'Severity  : ' + CONVERT(NVARCHAR(255), ERROR_SEVERITY())		            + CHAR(10)
	SET @tx_message += 'State     : ' + CONVERT(NVARCHAR(255), ERROR_STATE())				            + CHAR(10)
	SET @tx_message += '=================================================================='     + CHAR(10)

	/* Finish "run" as " Successfull" . */
  UPDATE rdp.run SET 
  
    id_processing_status = gnc_commen.id_processing_status(@ip_id_model, 'Failed'),
    tx_message           = @tx_message,
    dt_run_finished      = GETDATE()
  
  WHERE id_run = rdp.get_id_run(@ip_id_model, @ip_id_dataset);
  
  /* All is Well. */
  RETURN 0;

END
GO
