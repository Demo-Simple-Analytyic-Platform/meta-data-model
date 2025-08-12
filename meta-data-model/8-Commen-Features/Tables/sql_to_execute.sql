CREATE TABLE [rdp].[sql_to_execute] (
  	id_model char(32) NOT NULL, 
    id_dataset char(32) NOT NULL,
    tx_sql NVARCHAR(max), 
);
go
