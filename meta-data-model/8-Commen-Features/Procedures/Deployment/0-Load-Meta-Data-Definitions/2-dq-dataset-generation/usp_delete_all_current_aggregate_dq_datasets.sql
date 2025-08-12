CREATE PROCEDURE [deployment].[usp_delete_all_current_aggregate_dq_datasets] AS BEGIN
  DELETE FROM tsa_dta.tsa_dataset
  WHERE nm_target_schema IN ('dta_dq_aggregates', 'dqm')
  AND   id_model IN (SELECT id_model FROM mdm.current_model);
END
GO