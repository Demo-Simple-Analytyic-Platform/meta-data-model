CREATE TABLE [mdm].[last_deployment] (
	id_model      CHAR(32) NOT NULL PRIMARY KEY,
	dt_deployment DATETIME NOT NULL DEFAULT GETDATE()
)
