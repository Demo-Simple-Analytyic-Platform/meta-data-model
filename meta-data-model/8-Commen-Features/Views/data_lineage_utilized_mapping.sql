CREATE VIEW [mdm].[data_lineage_utilized_mapping] AS WITH

mdl AS (SELECT * FROM [dta].[model]                    WHERE meta_is_active = 1),
tgt AS (SELECT * FROM [dta].[dataset]                  WHERE meta_is_active = 1),
tgc AS (SELECT * FROM [dta].[attribute]                WHERE meta_is_active = 1),
prt AS (SELECT * FROM [dta].[transformation_part]      WHERE meta_is_active = 1),
ump AS (SELECT * FROM [dta].[transformation_mapping]   WHERE meta_is_active = 1),
uat AS (SELECT * FROM [dta].[transformation_attribute] WHERE meta_is_active = 1),
src AS (SELECT * FROM [dta].[attribute]                WHERE meta_is_active = 1),
srd AS (SELECT * FROM [dta].[dataset]                  WHERE meta_is_active = 1)

	SELECT id_model                  = mdl.id_model
			 , id_target_dataset         = tgt.id_dataset
			 , fn_target_dataset         = tgt.fn_dataset
			 , nm_target_schema          = tgt.nm_target_schema
			 , nm_target_table           = tgt.nm_target_table
			 , ni_target_ordering        = tgc.ni_ordering
			 , nm_target_colum           = tgc.nm_target_column	   
			 , ni_transformation_part    = prt.ni_transformation_part
			 , tx_source_mapping         = ump.tx_transformation_mapping
			 , nm_source_column          = src.nm_target_column
			 , nm_source_schema          = srd.nm_target_schema
			 , nm_source_table           = srd.nm_target_table

	FROM [dta].[model]                  AS mdl
	JOIN [dta].[dataset]                AS tgt ON tgt.id_model = mdl.id_model
	JOIN [dta].[attribute]              AS tgc ON tgc.id_model = tgt.id_model AND tgc.id_dataset             = tgt.id_dataset
	JOIN [dta].[transformation_part]	  AS prt ON prt.id_model = tgc.id_model AND prt.id_dataset             = tgt.id_dataset
	JOIN [dta].[transformation_mapping]	AS ump ON ump.id_model = prt.id_model AND ump.id_transformation_part = prt.id_transformation_part AND ump.id_attribute = tgc.id_attribute

	LEFT JOIN [dta].[transformation_attribute] AS uat ON uat.id_model = ump.id_model AND uat.id_transformation_mapping = ump.id_transformation_mapping
	LEFT JOIN [dta].[attribute]                AS src ON src.id_model = uat.id_model AND src.id_attribute              = uat.id_attribute
	LEFT JOIN [dta].[dataset]                  AS srd ON srd.id_model = src.id_model AND srd.id_dataset                = src.id_dataset
           
	WHERE tgt.meta_is_active = 1
