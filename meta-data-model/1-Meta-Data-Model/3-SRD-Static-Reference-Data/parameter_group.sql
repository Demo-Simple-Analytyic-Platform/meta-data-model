CREATE TABLE srd.parameter_group (

    /* Data Attributes */
    id_model           CHAR(32)      NULL,
    id_parameter_group CHAR(32)      NULL,
    cd_parameter_group NVARCHAR(32)  NULL,
    fn_parameter_group NVARCHAR(128) NULL,
    fd_parameter_group NVARCHAR(999) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT srd_parameter_group_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Parameter",
    "fd" : "The \"Parameter Grouos\" are the \"Descriptions\" of \"Groupss\" of "Parameters", for exampel parameters related the connection to Azure Storage Account.",
    "bk" : ["id_model", "cd_parameter_group"]
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'parameter_group';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Parameter Group",
    "fd" : "Unique Identiefier for srd.parameter_group"
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'parameter_group',
@level2type = N'COLUMN', @level2name = N'id_parameter_group';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Parameter Group Code",
    "fd" : "The \"Parameter Group Code\" is short 3 letter code to easy identify the \"Parameter\"-group."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'parameter_group',
@level2type = N'COLUMN', @level2name = N'cd_parameter_group';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Parameter Group Name",
    "fd" : "The \"Functional Name\" of the \"Parameter Group\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'parameter_group',
@level2type = N'COLUMN', @level2name = N'fn_parameter_group';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Parameter Group Description",
    "fd" : "The \"Functional Description\" of the \"Parameter Group\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'parameter_group',
@level2type = N'COLUMN', @level2name = N'fd_parameter_group';
GO
