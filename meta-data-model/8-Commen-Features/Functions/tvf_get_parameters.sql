CREATE FUNCTION rdp.tvf_get_parameters (
  
  /* Input Parameter(s) */
  @ip_id_model   CHAR(32),
  @ip_id_dataset CHAR(32)

) RETURNS @returntable TABLE (

    /* Output Columns */    
    cd_parameter_group NVARCHAR(32),
    ni_parameter_value INT,
    nm_parameter_value NVARCHAR(32),
    tx_parameter_value NVARCHAR(MAX)

) AS BEGIN INSERT @returntable

  SELECT pg.cd_parameter_group AS cd_parameter_group,
         pv.ni_parameter_value AS ni_parameter_value,
         pm.nm_parameter       AS nm_parameter_value,
         REPLACE(REPLACE(REPLACE(REPLACE(pv.tx_parameter_value, 
           '<@dt_previous_stand>', ISNULL(FORMAT(rn.dt_previous_stand, 'yyyy-MM-dd hh:mm:ss'),'<@dt_previous_stand>')),
           '<@dt_current_stand>',  ISNULL(FORMAT(rn.dt_current_stand,  'yyyy-MM-dd hh:mm:ss'),'<@dt_current_stand>')),
           '<@ni_previous_epoch>', ISNULL(CONVERT(NVARCHAR(10), rn.ni_previous_epoch),        '<@ni_previous_epoch>')),
           '<@ni_current_epoch>',  ISNULL(CONVERT(NVARCHAR(10), rn.ni_current_epoch),         '<@ni_current_epoch>')
         ) AS tx_parameter_value

  FROM dta.model           AS ml
  
  JOIN dta.parameter_value AS pv ON pv.meta_is_active = 1 AND pv.id_model = ml.id_model AND pv.id_dataset         = @ip_id_dataset

  JOIN dta.dataset         AS ds ON ds.meta_is_active = 1 AND ds.id_model = pv.id_model AND ds.id_dataset         = pv.id_dataset        
  JOIN srd.parameter       AS pm ON pm.meta_is_active = 1 AND pm.id_model = pv.id_model AND pm.id_parameter       = pv.id_parameter      
  JOIN srd.parameter_group AS pg ON pg.meta_is_active = 1 AND pg.id_model = pm.id_model AND pg.id_parameter_group = pm.id_parameter_group 
                                AND pg.cd_parameter_group != 'adf'

  LEFT JOIN rdp.run AS rn 
  ON  rn.id_dataset = ds.id_dataset 
  AND rn.id_model   = ds.id_model
  AND rn.dt_run_started = (
	  SELECT MAX(dt_run_started) 
    FROM rdp.run 
    WHERE id_model   = @ip_id_model
    AND   id_dataset = @ip_id_dataset
  )

  WHERE ml.meta_is_active = 1
  AND   ml.id_model       = @ip_id_model;

  RETURN

END
