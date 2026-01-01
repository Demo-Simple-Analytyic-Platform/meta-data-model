CREATE VIEW [deployment].[expected_objects] AS WITH
/*

  This view compares the expected database objects based on the metadata definitions in dta.dataset and the actual objects present in the database.

*/

cte_dta AS ( /* Tables and Procedures that are expected based on dta.dataset metadata */
  SELECT /* "Persistent Staging Area" (psa) and "Data Transformation Area" (dta) tables */
    nm_type    = 'Table',
    nm_schema  = dst.nm_target_schema, 
    nm_object  = dst.nm_target_table
  FROM dta.dataset AS dst
  WHERE dst.meta_is_active = 1
  UNION ALL
  SELECT /* "Temporal Staging Area" (tsa) tables */
    nm_type    = 'Table',
    nm_schema  = 'tsa_'+dst.nm_target_schema, 
    nm_object  = 'tsa_'+dst.nm_target_table
  FROM dta.dataset AS dst
  WHERE dst.meta_is_active = 1
  UNION ALL
  SELECT /* "Temporal Staging Landing" (tsl) tables */
    nm_type    = 'Table',
    nm_schema  = 'tsl_'+dst.nm_target_schema, 
    nm_object  = 'tsl_'+dst.nm_target_table
  FROM dta.dataset AS dst
  WHERE dst.meta_is_active = 1
  UNION ALL
  SELECT /* "User Specified Procedure" (usp) Stored Procedures */
    nm_type    = 'Procedure',
    nm_schema  = dst.nm_target_schema, 
    nm_object  = 'usp_'+dst.nm_target_table
  FROM dta.dataset AS dst
  WHERE dst.meta_is_active = 1
),
cte_mdm AS ( /* The "meta-data-model" has many object to help register metadata definiton and deployment logic and support for documentation in the form of Tables, Views, Procedures, Function and Synonyms that */
  SELECT 
    nm_type = CASE so.type 
                   WHEN 'U' THEN 'Table'
                   WHEN 'V' THEN 'View'
                   WHEN 'P' THEN 'Procedure'
                   WHEN 'FN' THEN 'Function'
                   WHEN 'IF' THEN 'Function'
                   WHEN 'TF' THEN 'Function'
                   WHEN 'SN' THEN 'Synonym'
                 END,
    nm_schema  = SCHEMA_NAME(so.schema_id),
    nm_object  = so.name
  FROM sys.objects AS so
  WHERE (
    SCHEMA_NAME(so.schema_id) IN (
      'mdm', 'srd', 'dta', 'dqm',  'ohg',
      'tsa_mdm', 'tsa_srd', 'tsa_dta', 'tsa_dqm', 'tsa_ohg',
      'deployment', 'documentation', 'rdp', 'gnc'
    )
    AND so.type IN ('U', 'V', 'P', 'FN', 'IF', 'TF', 'SN')
  ) OR (
    SCHEMA_NAME(so.schema_id)  = 'dbo' AND so.type = 'SN' AND so.name = 'f'
  )
),
cta_all AS (
  SELECT TOP 10000
    nm_type = CASE so.type 
                   WHEN 'U' THEN 'Table'
                   WHEN 'V' THEN 'View'
                   WHEN 'P' THEN 'Procedure'
                   WHEN 'FN' THEN 'Function'
                   WHEN 'IF' THEN 'Function'
                   WHEN 'TF' THEN 'Function'
                   WHEN 'SN' THEN 'Synonym'
                 END,
    nm_schema  = SCHEMA_NAME(so.schema_id),
    nm_object  = so.name
  FROM sys.objects AS so
  WHERE SCHEMA_NAME(so.schema_id) NOT IN (
    'sys', ''
  ) AND so.type IN ('U', 'V', 'P', 'FN', 'IF', 'TF', 'SN')
  ORDER BY nm_schema, nm_object
),
cte_expected AS ( /* All expected objects from both dta and mdm */
  SELECT 'adp' AS cd_domain, dta.* FROM cte_dta As dta
  WHERE NOT (dta.nm_schema IN ('tsa_mdm', 'tsl_mdm') AND dta.nm_object IN ('tsa_meta_attributes', 'tsl_meta_attributes'))
  AND   NOT (dta.nm_type = 'Procedure' AND dta.nm_schema = 'mdm' AND dta.nm_object = 'usp_meta_attributes')
  UNION ALL
  SELECT 'mdm' AS cd_domain, mdm.* FROM cte_mdm AS mdm 
  WHERE NOT EXISTS (
    SELECT 1 FROM cte_dta AS dta WHERE dta.nm_schema = mdm.nm_schema AND dta.nm_object = mdm.nm_object
  )
),
final_report AS (
  SELECT e.*,
    CASE
      WHEN a.nm_object IS     NULL AND e.nm_object IS NOT NULL THEN 'Missing in Database'
      WHEN a.nm_object IS NOT NULL AND e.nm_object IS     NULL THEN 'No Metadata Definitions'
      ELSE 'Found' 
    END AS cd_status_deployment
  FROM cte_expected AS e
  FULL OUTER JOIN cta_all AS a
    ON e.nm_schema = a.nm_schema AND e.nm_object = a.nm_object
)
SELECT *
FROM final_report
where cd_status_deployment <> 'Found'
--ORDER BY cd_domain ASC, nm_type ASC, nm_schema ASC, nm_object ASC
;
