CREATE VIEW [rdp].[run_with_duration] AS WITH
cte_run_with_tarteg_and_model AS (
	SELECT id_run            = run.id_run
		   , id_model          = run.id_model
		   , id_dataset        = dst.id_dataset
		   , nm_model          = mdl.nm_repository
		   , nm_target_schema  = dst.nm_target_schema
			 , dt_previous_stand = run.dt_previous_stand
			 , dt_current_stand  = run.dt_current_stand
		   , nm_target_table   = dst.nm_target_table 
		   , dt_run_started    = run.dt_run_started  
		   , dt_run_finished   = CASE WHEN run.dt_run_finished >= '9999-12-31' THEN GETDATE() ELSE CONVERT(DATETIME, ISNULL(run.dt_run_finished, GETDATE())) END
		   , ni_before         = run.ni_before
		   , ni_ingested       = run.ni_ingested
		   , ni_inserted       = run.ni_inserted
		   , ni_updated        = run.ni_updated
		   , ni_after          = run.ni_after
		   , tx_message        = run.tx_message
	FROM rdp.run AS run
	JOIN dta.dataset AS dst ON run.id_dataset = dst.id_dataset AND dst.meta_is_active = 1
	JOIN dta.model   AS mdl ON run.id_model   = mdl.id_model   AND mdl.meta_is_active = 1
)
SELECT rtm.id_run
     , rtm.id_model
		 , rtm.id_dataset
		 , rtm.nm_model
     , rtm.nm_target_schema
     , rtm.nm_target_table
		 , rtm.dt_previous_stand
		 , rtm.dt_current_stand
     , rtm.dt_run_started
     , rtm.dt_run_finished
     , rtm.ni_before
     , rtm.ni_ingested
     , rtm.ni_inserted
     , rtm.ni_updated
     , rtm.ni_after
     , rtm.tx_message
     , is_failed = CASE WHEN rtm.tx_message IS NOT NULL THEN 1 ELSE 0 END 
     , ni_duration = CASE 
	        WHEN DATEDIFF(MONTH,  rtm.dt_run_started, rtm.dt_run_finished) > 1 THEN -3
	        WHEN DATEDIFF(WEEK,   rtm.dt_run_started, rtm.dt_run_finished) > 1 THEN -2
	        WHEN DATEDIFF(DAY,    rtm.dt_run_started, rtm.dt_run_finished) > 1 THEN -1
	        ELSE DATEDIFF(SECOND, rtm.dt_run_started, rtm.dt_run_finished)
	   END 
FROM cte_run_with_tarteg_and_model AS rtm
--ORDER BY dt_run_started DESC
GO;
