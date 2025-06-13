CREATE PROCEDURE deployment.usp_add_all_meta_attributes AS BEGIN 

  INSERT INTO tsa_dta.tsa_attribute (id_attribute, id_dataset, id_datatype, fn_attribute, fd_attribute, ni_ordering, nm_target_column, is_businesskey, is_nullable)
  SELECT att.id_attribute, att.id_dataset, att.id_datatype, att.fn_attribute, att.fd_attribute, att.ni_ordering, att.nm_target_column, att.is_businesskey, att.is_nullable FROM (
    SELECT     
      id_attribute     = LOWER(CONVERT(char(32), HASHBYTES('MD5', CONCAT(CONVERT(NVARCHAR(MAX), ''), dst.id_dataset, '|', col.nm_target_column, '|')), 2)),
      id_dataset       = dst.id_dataset,
      id_datatype      = d.id_datatype,
      fn_attribute     = col.fn_attribute,
      fd_attribute     = col.fd_attribute,
      ni_ordering      = mxo.ni_ordering + dtp.ni_ordering,
      nm_target_column = col.nm_target_column,
      is_businesskey   = 0,
      is_nullable      = 0

    FROM tsa_dta.tsa_dataset AS dst

    JOIN (/* Get max of # Ordering */
      SELECT id_dataset, MAX(ni_ordering) AS ni_ordering
      FROM tsa_dta.tsa_attribute
      WHERE nm_target_column NOT IN ('meta_dt_valid_from', 'meta_dt_valid_till', 'meta_is_active', 'meta_ch_rh', 'meta_ch_bk', 'meta_ch_pk')
      GROUP BY id_dataset
    ) AS mxo ON mxo.id_dataset = dst.id_dataset

    CROSS JOIN ( /* Get functional "names" and "descriptions" from extented properties. */
      SELECT objname                                           AS nm_target_column, 
             JSON_VALUE(CONVERT(NVARCHAR(MAX), value), '$.fn') AS fn_attribute,
             JSON_VALUE(CONVERT(NVARCHAR(MAX), value), '$.fd') AS fd_attribute
      FROM fn_listextendedproperty (NULL, 'schema', 'mdm', 'table', 'meta_attributes', 'column', NULL)
    ) AS col
    
    JOIN ( /* Get the target columns for the meta attributes */
      SELECT 1 AS ni_ordering, 'ts' AS cd_prefix_column_name, 'meta_dt_valid_from' AS nm_target_column UNION
      SELECT 2 AS ni_ordering, 'ts' AS cd_prefix_column_name, 'meta_dt_valid_till' AS nm_target_column UNION 
      SELECT 3 AS ni_ordering, 'is' AS cd_prefix_column_name, 'meta_is_active'     AS nm_target_column UNION
      SELECT 4 AS ni_ordering, 'id' AS cd_prefix_column_name, 'meta_ch_rh'         AS nm_target_column UNION
      SELECT 5 AS ni_ordering, 'id' AS cd_prefix_column_name, 'meta_ch_bk'         AS nm_target_column UNION
      SELECT 6 AS ni_ordering, 'id' AS cd_prefix_column_name, 'meta_ch_pk'         AS nm_target_column 
    ) AS dtp ON dtp.nm_target_column = col.nm_target_column

    LEFT JOIN tsa_srd.tsa_datatype AS d ON d.cd_prefix_column_name = dtp.cd_prefix_column_name
  
  ) AS att LEFT JOIN tsa_dta.tsa_attribute AS ext ON ext.id_attribute = att.id_attribute

  WHERE ext.id_attribute IS NULL;

END
GO