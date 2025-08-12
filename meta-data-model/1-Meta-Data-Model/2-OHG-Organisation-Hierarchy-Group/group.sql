CREATE TABLE ohg.[group] (

    /* Data Attributes */
    id_model CHAR(32)      NULL,
    id_group CHAR(32)      NULL,
    fn_group NVARCHAR(128) NULL,
    fd_group NVARCHAR(999) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT ohg_group_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Groups",
    "fd" : "Business oriented \"Names\" and \"Descriptions\" of \"groups\" to organize, group and related \"Datasets\" into \"recognizable\" manner for the Business (and other (data) user.",
    "bk" : ["id_model", "fn_group"]
}',
@level0type = N'SCHEMA', @level0name = N'ohg',
@level1type = N'TABLE',  @level1name = N'group';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Group",
    "fd" : "Unique Identiefier for ohg.groups"
}',
@level0type = N'SCHEMA', @level0name = N'ohg',
@level1type = N'TABLE',  @level1name = N'group',
@level2type = N'COLUMN', @level2name = N'id_group';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Name",
    "fd" : "The \"Functional Name\" of the \"Group\" is \"placeholder\" for the business to organize/label \"Dataset(s)\" too provide insight and overview."
}',
@level0type = N'SCHEMA', @level0name = N'ohg',
@level1type = N'TABLE',  @level1name = N'group',
@level2type = N'COLUMN', @level2name = N'fn_group';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Description",
    "fd" : "The \"Functional Description\" of the \"Group\" provides the business to functionally \"describe\" a "group" or \"related\" \"Dataset(s)\" too provide insight and overview."
}',
@level0type = N'SCHEMA', @level0name = N'ohg',
@level1type = N'TABLE',  @level1name = N'group',
@level2type = N'COLUMN', @level2name = N'fd_group';
GO