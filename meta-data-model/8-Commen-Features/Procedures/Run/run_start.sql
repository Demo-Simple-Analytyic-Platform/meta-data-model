CREATE PROCEDURE rdp.run_start
  
  /* Input Parameters */
	@ip_id_model                 CHAR(32),
	@ip_id_dataset_or_dq_control CHAR(32),
	@ip_ds_external_reference_id NVARCHAR(999) = 'n/a',
	@ip_is_debugging             CHAR(1) = '0'
	
AS DECLARE /* Local Variables. */
	@dt_run_started DATETIME = GETDATE();

DECLARE 

	/* Local Varaibles for "Starting" run of "Dataset" or "DQ Control". */
	@id_run        CHAR(32) = LOWER(CONVERT(CHAR(32),HASHBYTES('MD5',CONCAT(CONVERT(NVARCHAR(MAX),''), '|', @ip_id_model, '|', @ip_id_dataset_or_dq_control, '|', CONVERT(VARCHAR(23), @dt_run_started, 121),'|')), 2)),
	@id_dataset    CHAR(32) = ISNULL((SELECT id_dataset    FROM dta.dataset    WHERE meta_is_active = 1 AND id_dataset    = @ip_id_dataset_or_dq_control), 'n/a'),
	@id_dq_control CHAR(32) = ISNULL((SELECT id_dq_control FROM dqm.dq_control WHERE meta_is_active = 1 AND id_dq_control = @ip_id_dataset_or_dq_control), 'n/a'),
	
	/* Local Variables for "Extraction" or " Processing Infromation". */
	@nm_target_schema   NVARCHAR(128) = (SELECT nm_target_schema FROM dta.dataset WHERE meta_is_active = 1 AND id_dataset = @ip_id_dataset_or_dq_control),
	@nm_target_table    NVARCHAR(128) = (SELECT nm_target_table  FROM dta.dataset WHERE meta_is_active = 1 AND id_dataset = @ip_id_dataset_or_dq_control),

	/* Local Variable for "not"-unique hased value for id_run. */
	@dt_run_started_nu DATETIME

DECLARE /* Local Variables for "Previous Stand". */
  @dt_previous_stand DATETIME      = CONVERT(DATETIME, '1970-01-01'),
	@tx_nwl            NVARCHAR(1)   = CHAR(10),
  @tx_emp            NVARCHAR(1)   = '',
  @tx_sql            NVARCHAR(MAX) = '';

BEGIN

	IF (1=1 /* "Start" run. */) BEGIN

		/* Finish "runs" that are NOT "finished". */
		UPDATE rdp.run SET 
			dt_run_finished      = @dt_run_started, 
			id_processing_status = gnc_commen.id_processing_status(@ip_id_model, 'Unfinished')
		WHERE id_model         = @ip_id_model
		AND   id_dataset       = @id_dataset
		AND   id_dq_control    = @id_dq_control 
		AND   ISNULL(dt_run_finished, CONVERT(DATETIME, '9999-12-31')) >= CONVERT(DATETIME, '9999-12-31');

		/* Check if @id_run is Unique */
		WHILE ((SELECT COUNT(*) FROM rdp.run WHERE id_run = @id_run) > 0) BEGIN
			SET @dt_run_started_nu = (SELECT TOP 1 dt_run_started FROM rdp.run WHERE id_run = @id_run);
			PRINT(CONCAT('The value of @id_run `', @id_run, '` was not unique! Hashed value was `', CONCAT(CONVERT(NVARCHAR(MAX),''),'|',@ip_id_dataset_or_dq_control,'|',CONVERT(VARCHAR(23), @dt_run_started, 121),'|'), '`.')); 
			PRINT(CONCAT('@ip_id_dataset_or_dq_control : `', @ip_id_dataset_or_dq_control, '`'));
			PRINT(CONCAT('@dt_run_started_nu           : `', CONVERT(VARCHAR(23), @dt_run_started_nu, 121)));
			SET @dt_run_started = GETDATE();
			SET @id_run         = LOWER(CONVERT(CHAR(32),HASHBYTES('MD5',CONCAT(CONVERT(NVARCHAR(MAX),''),'|',@ip_id_dataset_or_dq_control,'|',CONVERT(VARCHAR(23), @dt_run_started, 121),'|')), 2));
		END

		IF (1=1 /* Check if @id_dataset is valid, extract dt_previous_stand */) BEGIN

			IF (1=1 /* Create ##dt to prevent "warning" in SQL parsing of project. */) BEGIN
				BEGIN TRY
					SELECT GETDATE() AS previous_stand INTO ##dt;
				END TRY
				BEGIN CATCH
					/* Ignore error, table does not exist. */
				END CATCH;
			END
			
			/* Build and Execute SQL Statment to "Drop" temporal table ##dt if Exists. */
			SET @tx_sql = 'DROP TABLE IF EXISTS ##dt';
			EXEC sp_executesql @tx_sql;

			/* Build and Execute SQL Statment to "Create" ##dt. */
			SET @tx_sql  = @tx_nwl + 'SELECT MAX(u.dt) AS previous_stand INTO ##dt FROM (';
			SET @tx_sql += @tx_emp + '  SELECT MAX(meta_dt_valid_from) AS dt FROM <@nm_target_schema>.<@nm_target_table> UNION';
			SET @tx_sql += @tx_nwl + '  SELECT MAX(meta_dt_valid_till) AS dt FROM <@nm_target_schema>.<@nm_target_table> WHERE meta_dt_valid_till < CONVERT(DATE, "9999-12-31")';
			SET @tx_sql += @tx_nwl + ') AS u WHERE dt IS NOT NULL';
			SET @tx_sql = REPLACE(@tx_sql, '<@nm_target_schema>', @nm_target_schema);
			SET @tx_sql = REPLACE(@tx_sql, '<@nm_target_table>',  @nm_target_table);
			SET @tx_sql = REPLACE(@tx_sql, '"', '''');
			EXEC sp_executesql @tx_sql;

			/* Fetch dt.previous_stand */
			SELECT @dt_previous_stand = dt.previous_stand FROM ##dt AS dt;

		END;

		/* Insert new "run". */
		INSERT INTO rdp.run (
			id_run, 
			id_model, 
			id_dataset, 
			id_dq_control,
			ds_external_reference_id, 
			dt_previous_stand,
			dt_current_stand, 
			ni_previous_epoch,
			ni_current_epoch,
			id_processing_status,
			dt_run_started,
			dt_run_finished
		)
		SELECT 
			id_run                   = @id_run, 
			id_model                 = @ip_id_model,
			id_dataset               = @id_dataset, 
			id_dq_control            = @id_dq_control,
			ds_external_reference_id = @ip_ds_external_reference_id, 
			dt_previous_stand        = @dt_previous_stand,
			dt_current_stand         = @dt_run_started,
			ni_previous_epoch        = DATEDIFF(SECOND, CONVERT(DATETIME, '1970-01-01'), @dt_previous_stand),
			ni_current_epoch         = DATEDIFF(SECOND, CONVERT(DATETIME, '1970-01-01'), @dt_run_started),
			id_processing_status     = gnc_commen.id_processing_status(@ip_id_model, 'Started'),
			dt_run_started           = @dt_run_started,
			dt_run_finished          = CONVERT(DATETIME, '9999-12-31')

		FROM ( /* make "recordset" of @dt_run_started to ensure there is a record in de SELECT. */
			SELECT dt_current_stand  = @dt_run_started,
						 dt_previous_stand = @dt_previous_stand
		) AS std LEFT JOIN rdp.run AS run
		ON  run.id_dataset     = @id_dataset
		AND run.id_dq_control  = @id_dq_control
		AND run.dt_run_started = ( /* Find the "Previous" run that NOT ended in "Failed"-status. */
			SELECT MAX(dt_run_started) FROM rdp.run
			WHERE id_model             = @ip_id_model
			AND   id_dataset           = @id_dataset
			AND   id_dq_control        = @id_dq_control
			AND   id_processing_status = gnc_commen.id_processing_status(@ip_id_model, 'Finished')
		);

	END

	/* All is Well, return "new" ID. */
	RETURN 0;

END
GO