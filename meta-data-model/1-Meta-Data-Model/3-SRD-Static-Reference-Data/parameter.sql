CREATE TABLE srd.parameter (

    /* Data Attributes */
    id_model           CHAR(32)      NULL,
    id_parameter       CHAR(32)      NULL,
    id_parameter_group CHAR(32)      NULL,
    nm_parameter       NVARCHAR(32)  NULL,
    fn_parameter       NVARCHAR(128) NULL,
    fd_parameter       NVARCHAR(999) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT srd_parameter_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Parameter",
    "fd" : "The \"Parameter\" can be assigned to \"Datasets\" in combination with \"Values\" the information is to be used in the ETL-tooling, like \"Azure Data Factory\".",
    "bk" : ["id_model", "cd_parameter_group"]
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'parameter';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Parameter",
    "fd" : "Unique Identiefier for srd.parameter"
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'parameter',
@level2type = N'COLUMN', @level2name = N'id_parameter';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Parameter Group",
    "fd" : "Reference to \"Parameter Group\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'parameter',
@level2type = N'COLUMN', @level2name = N'id_parameter_group';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Parameter (Technical) Name",
    "fd" : "The \"Technical\"-name of the \"Parameter\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'parameter',
@level2type = N'COLUMN', @level2name = N'nm_parameter';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Parameter Name",
    "fd" : "The \"Functional Name\" of the \"Parameter\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'parameter',
@level2type = N'COLUMN', @level2name = N'fn_parameter';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Parameter Description",
    "fd" : "The \"Functional Description\" of the \"Parameter\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'parameter',
@level2type = N'COLUMN', @level2name = N'fd_parameter';
GO