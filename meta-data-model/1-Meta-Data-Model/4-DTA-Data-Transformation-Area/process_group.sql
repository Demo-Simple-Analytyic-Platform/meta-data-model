CREATE VIEW dta.process_group AS WITH

n AS ( /* Node */
  SELECT dst.id_model                                                                    AS id_model,
         dst.id_dataset                                                                  AS id_dataset,
         dst.is_ingestion                                                                AS is_ingestion,
         CONCAT(dst.nm_target_schema, '.usp_', dst.nm_target_table)                      AS nm_procedure,
         CASE WHEN dst.is_ingestion = 1 THEN 'tsl_'+ dst.nm_target_schema ELSE 'n/a' END AS nm_tsl_schema,
         CASE WHEN dst.is_ingestion = 1 THEN 'tsl_'+ dst.nm_target_table  ELSE 'n/a' END AS nm_tsl_table,
         dst.nm_target_schema                                                            AS nm_tgt_schema,
         dst.nm_target_table                                                             AS nm_tgt_table
  FROM dta.dataset AS dst
  WHERE dst.meta_is_active = 1
),

e AS ( /* Edge */
  SELECT DISTINCT
         tds.id_model   AS id_model,
         tds.id_dataset AS id_dataset_source,
         prt.id_dataset AS id_dataset_target
  FROM dta.transformation_part AS prt
    LEFT JOIN dta.transformation_dataset AS tds 
    ON  tds.meta_is_active         = 1 
    AND tds.id_model               = prt.id_model
    AND tds.id_transformation_part = prt.id_transformation_part
  WHERE prt.meta_is_active = 1 
)

SELECT d00.id_model
     , d00.id_dataset
     , d00.is_ingestion
     , d00.nm_procedure
     , d00.nm_tsl_schema
     , d00.nm_tsl_table     
     , d00.nm_tgt_schema
     , d00.nm_tgt_table
     , ni_process_group = MAX(IIF(d01.id_dataset_source IS NOT NULL, 1, 0)
                             +IIF(d02.id_dataset_source IS NOT NULL, 1, 0)
                             +IIF(d03.id_dataset_source IS NOT NULL, 1, 0)
                             +IIF(d04.id_dataset_source IS NOT NULL, 1, 0)
                             +IIF(d05.id_dataset_source IS NOT NULL, 1, 0)
                             +IIF(d06.id_dataset_source IS NOT NULL, 1, 0)
                             +IIF(d07.id_dataset_source IS NOT NULL, 1, 0)
                             +IIF(d08.id_dataset_source IS NOT NULL, 1, 0)
                             +IIF(d09.id_dataset_source IS NOT NULL, 1, 0)
                             +IIF(d10.id_dataset_source IS NOT NULL, 1, 0))

FROM n AS d00

  LEFT JOIN e AS d01 ON d01.id_dataset_target = d00.id_dataset        AND d01.id_model = d00.id_model 
  LEFT JOIN e AS d02 ON d02.id_dataset_target = d01.id_dataset_source AND d02.id_model = d01.id_model
  LEFT JOIN e AS d03 ON d03.id_dataset_target = d02.id_dataset_source AND d03.id_model = d02.id_model
  LEFT JOIN e AS d04 ON d04.id_dataset_target = d03.id_dataset_source AND d04.id_model = d03.id_model
  LEFT JOIN e AS d05 ON d05.id_dataset_target = d04.id_dataset_source AND d05.id_model = d04.id_model
  LEFT JOIN e AS d06 ON d06.id_dataset_target = d05.id_dataset_source AND d06.id_model = d05.id_model
  LEFT JOIN e AS d07 ON d07.id_dataset_target = d06.id_dataset_source AND d07.id_model = d06.id_model
  LEFT JOIN e AS d08 ON d08.id_dataset_target = d07.id_dataset_source AND d08.id_model = d07.id_model
  LEFT JOIN e AS d09 ON d09.id_dataset_target = d08.id_dataset_source AND d09.id_model = d08.id_model
  LEFT JOIN e AS d10 ON d10.id_dataset_target = d09.id_dataset_source AND d10.id_model = d09.id_model


GROUP BY d00.id_model
       , d00.id_dataset
       , d00.is_ingestion
       , d00.nm_procedure
       , d00.nm_tsl_schema
       , d00.nm_tsl_table     
       , d00.nm_tgt_schema
       , d00.nm_tgt_table
GO