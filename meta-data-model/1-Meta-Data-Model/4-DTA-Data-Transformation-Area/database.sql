CREATE TABLE dta.[database] (

    /* Data Attributes */
    id_model                  CHAR(32)      NULL,
    id_database               CHAR(32)      NULL,
    id_environment            CHAR(32)      NULL,
    nm_server                 NVARCHAR(128) NULL,
    nm_database               NVARCHAR(128) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_database_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Database",
    "fd" : "Meta Data of the \"Database\", mainly server, environment and database itself.",
    "bk" : ["id_model", "nm_server", "nm_database"]
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'database';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Model",
    "fd" : "Reference to \"Model\""
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'database',
@level2type = N'COLUMN', @level2name = N'id_model';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Database",
    "fd" : "Unique Identiefier for dta.database"
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'database',
@level2type = N'COLUMN', @level2name = N'id_database';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID environment",
    "fd" : "Reference to \"Environment\" (Development-Status is re-used here)."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'database',
@level2type = N'COLUMN', @level2name = N'id_environment';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Server Name",
    "fd" : "Technical Server Name for the \"Database\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'database',
@level2type = N'COLUMN', @level2name = N'nm_server';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Database Name",
    "fd" : "The \"Technical Name\" of the \"Database\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'database',
@level2type = N'COLUMN', @level2name = N'nm_database';
GO