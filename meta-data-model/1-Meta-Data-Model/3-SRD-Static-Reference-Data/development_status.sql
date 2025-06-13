CREATE TABLE srd.development_status (

    /* Data Attributes */
    id_model              CHAR(32)      NULL,
    id_development_status CHAR(32)      NULL,
    cd_development_status NVARCHAR(32)  NULL,
    nm_development_status NVARCHAR(128) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT srd_development_status_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Development Status",
    "fd" : "List of \""Development\"-statusses for \"Datasets\", \"DQ Controls\" and \"DQ Requirements\" with a developer can control which \"Definitons\" are used within whcih \"Environment\". Allowing to do \"Production\"-validation without disruption current running processes.",
    "bk" : ["id_model", "cd_development_status"]
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'development_status';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Development Status",
    "fd" : "Unique Identiefier for srd.development_status"
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'development_status',
@level2type = N'COLUMN', @level2name = N'id_development_status';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Development Status Code",
    "fd" : "The \"Code\" of the \"Development Status\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'development_status',
@level2type = N'COLUMN', @level2name = N'cd_development_status';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Development Status Name",
    "fd" : "The \"Name\" of the \"Development Status\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'development_status',
@level2type = N'COLUMN', @level2name = N'nm_development_status';
GO