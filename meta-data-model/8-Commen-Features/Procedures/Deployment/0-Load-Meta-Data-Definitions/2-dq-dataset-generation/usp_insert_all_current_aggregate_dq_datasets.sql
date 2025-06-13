CREATE PROCEDURE [deployment].[usp_insert_all_current_aggregate_dq_datasets] AS BEGIN
  INSERT INTO tsa_dta.tsa_dataset (id_model, id_dataset, id_development_status, id_group, is_ingestion, fn_dataset, fd_dataset, nm_target_schema, nm_target_table, tx_source_query) 
  SELECT id_model, id_dataset, id_development_status, id_group, is_ingestion, fn_dataset, fd_dataset, nm_target_schema, nm_target_table, tx_source_query
  FROM dta.dataset
  WHERE meta_is_active = 1
  AND   id_model IN (SELECT id_model FROM mdm.current_model)
  AND   nm_target_schema IN ('dta_dq_aggregates', 'dqm');
END
GO