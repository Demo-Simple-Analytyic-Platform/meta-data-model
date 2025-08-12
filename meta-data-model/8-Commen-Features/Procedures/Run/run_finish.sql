CREATE PROCEDURE rdp.run_finish
  
  /* Input Parameters */
  @ip_id_model    CHAR(32),
  @ip_id_dataset  CHAR(32),
  @ip_ni_before   INT,
  @ip_ni_ingested INT,
  @ip_ni_inserted INT,
  @ip_ni_updated  INT,
  @ip_ni_after    INT

AS BEGIN

	/* Finish "run" as " Successfull" . */
  UPDATE rdp.run SET 

    id_processing_status = gnc_commen.id_processing_status(@ip_id_model, 'Finished'),
    dt_run_finished      = GETDATE(),
    ni_before            = @ip_ni_before,
    ni_ingested          = @ip_ni_ingested,
    ni_inserted          = @ip_ni_inserted,
    ni_updated           = @ip_ni_updated,
    ni_after             = @ip_ni_after

  WHERE id_run = rdp.get_id_run(@ip_id_model, @ip_id_dataset);
  
  /* All is Well. */
  RETURN 0;

END
GO
