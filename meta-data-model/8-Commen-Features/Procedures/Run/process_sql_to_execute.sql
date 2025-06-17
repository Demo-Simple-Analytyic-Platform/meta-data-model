CREATE PROCEDURE rdp.process_sql_to_execute
	@ip_id_model char(32),
	@ip_id_dataset char(32)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @tx_sql NVARCHAR(max) = (SELECT top 1 tx_sql FROM rdp.sql_to_execute where id_model = @ip_id_model and id_dataset = @ip_id_dataset);
	EXEC sys.sp_executesql @tx_sql;
	DELETE FROM rdp.sql_to_execute WHERE id_model = @ip_id_model and id_dataset = @ip_id_dataset;

END
GO