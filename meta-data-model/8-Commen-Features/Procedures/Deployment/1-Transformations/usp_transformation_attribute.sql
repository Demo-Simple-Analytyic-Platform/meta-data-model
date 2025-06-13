CREATE PROCEDURE deployment.usp_transformation_attribute
    
    /* Input Parameters */
    @ip_id_transformation_mapping CHAR(32),

    /* Input Parameters */
    @ip_is_debugging BIT = 0,
    @ip_is_testing   BIT = 0

AS DECLARE /* Local Variables */

  /* Current Model */
  @id_model CHAR(32) = (SELECT id_model FROM mdm.current_model) 

BEGIN 

  IF (1=1 /* "Temp"-table: rs -> "Resultset". */) BEGIN
    DROP TABLE IF EXISTS #attribute; 
      SELECT * INTO #attribute FROM (
        SELECT id_model
             , id_attribute
             , id_dataset
             , nm_target_column
             , meta_is_active
        FROM dta.attribute
        WHERE meta_is_active = 1

        UNION ALL

        SELECT id_model, id_attribute = LOWER(CONVERT(CHAR(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''), '|', id_dataset, '|', 'meta_dt_valid_from', '|' )), 2)), id_dataset, 'meta_dt_valid_from' AS nm_target_column, 1 AS meta_is_active FROM dta.dataset WHERE meta_is_active = 1 UNION ALL
        SELECT id_model,  id_attribute = LOWER(CONVERT(CHAR(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''), '|', id_dataset, '|', 'meta_dt_valid_till', '|' )), 2)), id_dataset, 'meta_dt_valid_till' AS nm_target_column, 1 AS meta_is_active FROM dta.dataset WHERE meta_is_active = 1 UNION ALL
        SELECT id_model,  id_attribute = LOWER(CONVERT(CHAR(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''), '|', id_dataset, '|', 'meta_is_active',     '|' )), 2)), id_dataset, 'meta_is_active'     AS nm_target_column, 1 AS meta_is_active FROM dta.dataset WHERE meta_is_active = 1 UNION ALL
        SELECT id_model,  id_attribute = LOWER(CONVERT(CHAR(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''), '|', id_dataset, '|', 'meta_ch_rh',         '|' )), 2)), id_dataset, 'meta_ch_rh'         AS nm_target_column, 1 AS meta_is_active FROM dta.dataset WHERE meta_is_active = 1 UNION ALL
        SELECT id_model,  id_attribute = LOWER(CONVERT(CHAR(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''), '|', id_dataset, '|', 'meta_ch_bk',         '|' )), 2)), id_dataset, 'meta_ch_bk'         AS nm_target_column, 1 AS meta_is_active FROM dta.dataset WHERE meta_is_active = 1 UNION ALL
        SELECT id_model,  id_attribute = LOWER(CONVERT(CHAR(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''), '|', id_dataset, '|', 'meta_ch_pk',         '|' )), 2)), id_dataset, 'meta_ch_pk'         AS nm_target_column, 1 AS meta_is_active FROM dta.dataset WHERE meta_is_active = 1
      ) AS u;


    DROP TABLE IF EXISTS #tsa_transformation_attribute; SELECT DISTINCT
      
      LOWER(CONVERT(CHAR(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''), 
        '|', map.id_model,
        '|', map.id_transformation_mapping,
        '|', att.id_model, /* id_model_source */
        '|', att.id_attribute,
        '|')), 2)) AS id_transformation_attribute,

      map.id_model,
      map.id_transformation_mapping,
      att.id_model AS id_source_model,
      att.id_attribute,

      map.id_transformation_part,
      map.tx_transformation_mapping,
	    
      dst.id_dataset,
	    dst.nm_target_schema,
	    dst.nm_target_table,
	    att.nm_target_column

    INTO #tsa_transformation_attribute

    FROM tsa_dta.tsa_transformation_mapping AS map

    LEFT JOIN dta.transformation_dataset AS tds ON tds.meta_is_active = 1 AND tds.id_transformation_part = map.id_transformation_part AND tds.id_model = map.id_model
    
    AND CASE /* match "Alias" to "Utilized"-dataset of transformation_dataset. */
          WHEN CHARINDEX(''  + tds.cd_alias +  '.', map.tx_transformation_mapping) > 0 THEN 1
          WHEN CHARINDEX('[' + tds.cd_alias + '].', map.tx_transformation_mapping) > 0 THEN 1
		      ELSE 0
        END = 1

    LEFT JOIN dta.dataset   AS dst ON dst.meta_is_active = 1 AND dst.id_dataset = tds.id_dataset
    LEFT JOIN dta.attribute AS att ON att.meta_is_active = 1 AND att.id_dataset = dst.id_dataset AND att.id_model = dst.id_model

    
    AND CASE /* match "Name" of "Utilized"-column in text of tx_transformation_mapping. */
          WHEN CHARINDEX(''  + tds.cd_alias +  '.'  + att.nm_target_column +  '', map.tx_transformation_mapping) > 0 THEN 1
          WHEN CHARINDEX('[' + tds.cd_alias + '].'  + att.nm_target_column +  '', map.tx_transformation_mapping) > 0 THEN 1
		      WHEN CHARINDEX(''  + tds.cd_alias +  '.[' + att.nm_target_column + ']', map.tx_transformation_mapping) > 0 THEN 1
		      WHEN CHARINDEX('[' + tds.cd_alias + '].[' + att.nm_target_column + ']', map.tx_transformation_mapping) > 0 THEN 1
		      ELSE 0
	    END = 1

    WHERE map.id_transformation_mapping = @ip_id_transformation_mapping
    AND   att.id_attribute IS NOT NULL;

  END;

  IF (@ip_is_testing = 0 /* If NOT in Testing-mode */) BEGIN
    INSERT INTO tsa_dta.tsa_transformation_attribute (
      id_model, id_transformation_attribute, id_transformation_mapping, id_source_model, id_attribute
    ) SELECT 
      @id_model, id_transformation_attribute, id_transformation_mapping, id_source_model, id_attribute
    FROM #tsa_transformation_attribute;
  END

END
GO