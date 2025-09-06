CREATE FUNCTION [dta].[parallel_proces_group] (
  
  /* Input Parameter(s) */
  @ip_id_model    CHAR(32),
  @ip_ni_process_group INT,
  @ip_ni_session  INT,
  @ip_id_session  INT

) RETURNS @returntable TABLE (

    /* Output Columns */    
    id_model           CHAR(32),
	nm_target_schema   NVARCHAR(128),
	nm_target_table    NVARCHAR(128)

) AS BEGIN INSERT @returntable 
  SELECT id_model, nm_target_schema, nm_target_table
  FROM (
    SELECT pgp.id_model         AS id_model
	     , pgp.nm_tgt_schema    AS nm_target_schema
		 , pgp.nm_tgt_table     AS nm_target_table
		 , pgp.ni_process_group	AS ni_process_group
		 , ROW_NUMBER() OVER ( 
		     PARTITION BY pgp.id_model, pgp.ni_process_group
			     ORDER BY pgp.nm_tgt_schema, pgp.nm_tgt_table
		   ) as ni_index
    FROM dta.process_group AS pgp
	WHERE id_model = @ip_id_model
	AND   ni_process_group = @ip_ni_process_group
  ) AS pgp
  WHERE (ni_index % @ip_ni_session) + 1 = @ip_id_session;

  RETURN

END
GO
