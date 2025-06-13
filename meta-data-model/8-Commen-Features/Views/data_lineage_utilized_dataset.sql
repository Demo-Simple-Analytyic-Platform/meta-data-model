CREATE VIEW [mdm].[data_lineage_utilized_dataset] AS

-- Utilized Datasets
SELECT id_model                  = mdl.id_model
     
     , id_target_dataset         = tgt.id_dataset
     , fn_target_dataset         = tgt.fn_dataset
     , nm_target_schema          = tgt.nm_target_schema
     , nm_target_table           = tgt.nm_target_table
	 
	   , ni_transformation_part    = prt.ni_transformation_part
	   , ni_transformation_dataset = uds.ni_transformation_dataset
     
	   , id_source_dataset         = src.id_dataset
     , nm_source_dataset         = src.fn_dataset
     , nm_source_schema          = src.nm_target_schema
     , nm_source_table           = src.nm_target_table
	   , cd_join_type              = uds.cd_join_type
	   , cd_alias                  = uds.cd_alias
	   , tx_join_criteria          = uds.tx_join_criteria
	
FROM [dta].[model]                  AS mdl
JOIN [dta].[dataset]                AS tgt ON tgt.meta_is_active = 1 AND tgt.id_model               = mdl.id_model
JOIN [dta].[transformation_part]	  AS prt ON prt.meta_is_active = 1 AND prt.id_dataset             = tgt.id_dataset
JOIN [dta].[transformation_dataset]	AS uds ON uds.meta_is_active = 1 AND uds.id_transformation_part = prt.id_transformation_part
JOIN [dta].[dataset]			         	AS src ON src.meta_is_active = 1 AND src.id_dataset             = uds.id_dataset

WHERE tgt.meta_is_active = 1