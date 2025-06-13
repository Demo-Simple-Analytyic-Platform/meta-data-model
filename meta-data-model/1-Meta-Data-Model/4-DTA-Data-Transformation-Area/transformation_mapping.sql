CREATE TABLE dta.transformation_mapping (

    /* Data Attributes */
    id_model                                CHAR(32)      NULL,
    id_transformation_mapping               CHAR(32)      NULL,
    id_transformation_part                  CHAR(32)      NULL,
    id_attribute                            CHAR(32)      NULL,
    is_in_group_by                          BIT           NULL,
    tx_transformation_mapping               NVARCHAR(MAX) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_transformation_mapping_pk PRIMARY KEY (meta_ch_pk),

);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Transformation Mapping",
    "fd" : "List of \"prefered\" transformation_mapping, with prefix for column-name and \"functional\"-name/description templates.",
    "bk" : ["id_model", "id_transformation_part", "id_attribute"]
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_mapping';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Transformation Mapping",
    "fd" : "Unique Identiefier for dta.transformation_mapping"
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_mapping',
@level2type = N'COLUMN', @level2name = N'id_transformation_mapping';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Transformation Part",
    "fd" : "Reference to \"Transformation Part\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_mapping',
@level2type = N'COLUMN', @level2name = N'id_transformation_part';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Attribute",
    "fd" : "Reference to \"Attribute\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_mapping',
@level2type = N'COLUMN', @level2name = N'id_attribute';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Name (transformation_mapping)",
    "fd" : "The \"Functional Name\" of the \"transformation_mapping\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_mapping',
@level2type = N'COLUMN', @level2name = N'is_in_group_by';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Description (transformation_mapping)",
    "fd" : "The \"Functional Description\" of the \"transformation_mapping\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_mapping',
@level2type = N'COLUMN', @level2name = N'tx_transformation_mapping';
GO
