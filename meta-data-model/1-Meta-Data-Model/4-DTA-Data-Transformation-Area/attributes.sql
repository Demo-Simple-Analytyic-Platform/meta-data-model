CREATE TABLE dta.attribute (

    /* Data Attributes */
    id_model                  CHAR(32)      NULL,
    id_attribute              CHAR(32)      NULL,
    id_dataset                CHAR(32)      NULL,
    id_datatype               CHAR(32)      NULL,
    fn_attribute              NVARCHAR(128) NULL,
    fd_attribute              NVARCHAR(999) NULL,
    ni_ordering               INT           NULL,
    nm_target_column          NVARCHAR(128) NULL,
    is_businesskey            BIT           NULL,
    is_nullable               BIT           NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_attribute_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Attributes",
    "fd" : "List of \"Attributes\" of a \"Dataset\".",
    "bk" : ["id_model", "id_dataset", "fn_attribute"]
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'attribute';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Attribute",
    "fd" : "Unique Identiefier for dta.attribute"
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'attribute',
@level2type = N'COLUMN', @level2name = N'id_attribute';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset",
    "fd" : "Reference to \"Dataset\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'attribute',
@level2type = N'COLUMN', @level2name = N'id_dataset';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Datatype",
    "fd" : "Reference to \"Datatype\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'attribute',
@level2type = N'COLUMN', @level2name = N'id_datatype';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Name (Attribute)",
    "fd" : "The \"Functional Name\" of the \"Attribute\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'attribute',
@level2type = N'COLUMN', @level2name = N'fn_attribute';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Description (Attribute)",
    "fd" : "The \"Functional Description\" of the \"Attribute\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'attribute',
@level2type = N'COLUMN', @level2name = N'fd_attribute';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "# Ordering",
    "fd" : "Ordering of the \"Attributes\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'attribute',
@level2type = N'COLUMN', @level2name = N'ni_ordering';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Target Column Name",
    "fd" : "The \"Name\" of the \"Target Column\", this is the name in the table in the database."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'attribute',
@level2type = N'COLUMN', @level2name = N'nm_target_column';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Is Businesskey",
    "fd" : "The \"Attributel\" is indicated as a \"Businesskey\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'attribute',
@level2type = N'COLUMN', @level2name = N'is_businesskey';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Is Nullable",
    "fd" : "The \"Attribute\" is allowed to be \"Empty\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'attribute',
@level2type = N'COLUMN', @level2name = N'is_nullable';
GO