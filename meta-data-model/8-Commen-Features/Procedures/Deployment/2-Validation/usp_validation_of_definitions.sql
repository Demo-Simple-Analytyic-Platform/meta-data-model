CREATE PROCEDURE deployment.check_for_validation_issues 

  /* Input Parameters */
  @ip_is_debugging BIT = 0

AS BEGIN

  BEGIN /* Create mdm.validation_issues if not exists and clean up previous deplyment issues. */
   
    /* Clean uo previous Deployment validation result */
    DELETE FROM mdm.validation_issues WHERE id_model IN (SELECT id_model FROM mdm.current_model);

  END

  IF (1=1 /* Validate that all "utilized" datasets in "Transformations" have a "Alias" assigned. */) BEGIN
    INSERT INTO mdm.validation_issues (id_model, id_dataset, nm_dataset, id_attribute, nm_attribute, nm_validation_issue, ds_validation_issue)
    SELECT
      id_model            = mdl.id_model,
      id_dataset          = tgt.id_dataset,
      nm_dataset          = tgt.nm_target_schema + '.' + tgt.nm_target_table,
      id_attribute        = NULL,
      nm_attribute        = NULL,
      nm_validation_issue = 'Missing "Alias"!',
      ds_validation_issue = 'For "Transformation" named "' + tgt.fn_dataset + '" the utilized dataset "' + src.fn_dataset + '" has NO "Alias".'

    FROM tsa_dta.tsa_transformation_dataset AS uds
    JOIN tsa_dta.tsa_transformation_part    AS prt ON prt.id_transformation_part = uds.id_transformation_part
    JOIN tsa_dta.tsa_dataset                AS tgt ON tgt.id_dataset = prt.id_dataset
    LEFT JOIN tsa_dta.tsa_dataset           AS src ON src.id_dataset = uds.id_dataset
    CROSS JOIN mdm.current_model AS mdl
    WHERE uds.cd_alias IS NULL;
  END

  IF (1=1 /* Validate that all "Ingerstion" have paramters for the dataset assigned. */) BEGIN
    INSERT INTO mdm.validation_issues (id_model, id_dataset, nm_dataset, id_attribute, nm_attribute, nm_validation_issue, ds_validation_issue)
    SELECT 
      id_model            = mdl.id_model,
      id_dataset          = dst.id_dataset,
      nm_dataset          = dst.nm_target_schema + '.' + dst.nm_target_table,
      id_attribute        = NULL,
      nm_attribute        = NULL,
      nm_validation_issue = 'Missing "Parameters"!',
      ds_validation_issue = 'For "Ingestion" named "' + dst.fn_dataset + '" the "Parameters" are missing!'

    FROM tsa_dta.tsa_dataset AS dst
    LEFT JOIN tsa_dta.tsa_parameter_value AS par ON par.id_dataset = dst.id_dataset
    CROSS JOIN mdm.current_model AS mdl  
    WHERE par.id_dataset IS NULL
    AND   dst.is_ingestion = 1;

  END

  IF ((SELECT COUNT(*) FROM mdm.validation_issues) > 0) BEGIN
  
    DECLARE @tx NVARCHAR(MAX) = (SELECT * FROM mdm.validation_issues WHERE id_model IN (SELECT id_model FROM mdm.current_model) FOR JSON AUTO),
            @ni INT,
            @mx INT,
            @mg NVARCHAR(999);
    BEGIN

      SET @mx = mdm.json_count(@tx); SET @ni = 0; WHILE (@ni < @mx) BEGIN 
      
        SET @mg  = CHAR(10) + 'id_dataset          : ' + ISNULL(mdm.json_value(@ni, @tx, 'id_dataset'),          'n/a')
        SET @mg += CHAR(10) + 'nm_dataset          : ' + ISNULL(mdm.json_value(@ni, @tx, 'nm_dataset'),          'n/a')
        SET @mg += CHAR(10) + 'id_attribute        : ' + ISNULL(mdm.json_value(@ni, @tx, 'id_attribute'),        'n/a')
        SET @mg += CHAR(10) + 'nm_attribute        : ' + ISNULL(mdm.json_value(@ni, @tx, 'nm_attribute'),        'n/a')
        SET @mg += CHAR(10) + 'nm_validation_issue : ' + ISNULL(mdm.json_value(@ni, @tx, 'nm_validation_issue'), 'n/a')
        SET @mg += CHAR(10) + 'ds_validation_issue : ' + ISNULL(mdm.json_value(@ni, @tx, 'ds_validation_issue'), 'n/a')
        EXEC gnc_commen.to_concol_window @mg;
      
      SET @ni += 1; END    

      --RAISERROR('Various Error where detected in the Definitions of the metadata!', 16, 1);

    END

  END;

END;
GO

