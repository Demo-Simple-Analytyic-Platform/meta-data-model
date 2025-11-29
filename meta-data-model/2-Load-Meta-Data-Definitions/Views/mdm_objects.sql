CREATE VIEW deployment.mdm_objects AS SELECT 
  nm_schema = TABLE_SCHEMA, 
  nm_table  = TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE CASE 

        WHEN TABLE_SCHEMA = 'dta' AND TABLE_NAME IN (
          'model', 
          'database', 
          'dataset', 
          'attribute', 
          'ingestion_etl', 
          'parameter_value', 
          'schedule'
        ) THEN 1

        WHEN TABLE_SCHEMA = 'dta' AND TABLE_NAME IN (
          'transformation_part',
          'transformation_part_attribute',
          'transformation_dataset', 
          'transformation_dataset_attribute', 
          'transformation_column_mapping', 
          'transformation_column_mapping_attribute'
        ) THEN 1

        WHEN TABLE_SCHEMA = 'dqm' AND TABLE_NAME IN (
          'dq_requirement', 
          'dq_control',
          'dq_threshold'
        ) THEN 1

        WHEN TABLE_SCHEMA = 'srd' AND TABLE_NAME IN (
          'development_status', 
          'datatype', 
          'parameter', 
          'parameter_group', 
          'dq_dimension', 
          'dq_risk_level', 
          'dq_result_status', 
          'dq_review_status', 
          'processing_status', 
          'processing_step'
        ) THEN 1

        WHEN TABLE_SCHEMA = 'ohg' AND TABLE_NAME IN (
          'group', 
          'hierarchy', 
          'related'
        ) THEN 1
            
        ELSE 0

      END = 1;
