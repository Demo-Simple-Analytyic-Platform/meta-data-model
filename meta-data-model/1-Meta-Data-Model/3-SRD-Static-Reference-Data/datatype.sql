CREATE TABLE srd.datatype (

    /* Data Attributes */
    id_model                  CHAR(32)      NULL,
    id_datatype               CHAR(32)      NULL,
    fn_datatype               NVARCHAR(128) NULL,
    fd_datatype               NVARCHAR(999) NULL,
    cd_target_datatype        NVARCHAR(32)  NULL,
    cd_prefix_column_name     NVARCHAR(32)  NULL,
    cd_symbol_functional_naam NVARCHAR(32)  NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT srd_datatype_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Datatype",
    "fd" : "List of \"prefered\" datatype, with prefix for column-name and \"functional\"-name/description templates.",
    "bk" : ["id_model", "fn_datatype"]
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'datatype';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Datatype",
    "fd" : "Unique Identiefier for srd.datatype"
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'datatype',
@level2type = N'COLUMN', @level2name = N'id_datatype';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Name (Datatype)",
    "fd" : "The \"Functional Name\" of the \"Datatype\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'datatype',
@level2type = N'COLUMN', @level2name = N'fn_datatype';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Description (Datatype)",
    "fd" : "The \"Functional Description\" of the \"Datatype\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'datatype',
@level2type = N'COLUMN', @level2name = N'fd_datatype';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Datatype",
    "fd" : "The \"technical\"-definition of the \"Datatype\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'datatype',
@level2type = N'COLUMN', @level2name = N'cd_target_datatype';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Prefix Column Name",
    "fd" : "The \"prefix\" of the \"Column\"-name."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'datatype',
@level2type = N'COLUMN', @level2name = N'cd_prefix_column_name';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Symbol",
    "fd" : "The \"Symbol\" of the \"Datatype\" for the \"Functional\"-name of short-name of attribute in the \"Presentation\"-model."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'datatype',
@level2type = N'COLUMN', @level2name = N'cd_symbol_functional_naam';
GO