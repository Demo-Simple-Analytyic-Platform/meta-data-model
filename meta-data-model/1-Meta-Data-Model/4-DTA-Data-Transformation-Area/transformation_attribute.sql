CREATE TABLE dta.transformation_attribute (

    /* Data Attributes */
    id_model                                CHAR(32) NULL,
    id_transformation_attribute             CHAR(32) NULL,
    id_transformation_mapping               CHAR(32) NULL,
    id_source_model                         CHAR(32) NULL,
    id_attribute                            CHAR(32) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_transformation_attribute_pk PRIMARY KEY (meta_ch_pk),

);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Transformation Attribute",
    "fd" : "List of \"Utilized Attributes\" for a \"Transformation Mapping\".",
    "bk" : ["id_model", "id_transformation_mapping", "id_attribute"]
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_attribute';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Transformation Attribute",
    "fd" : "Unique Identiefier for dta.transformation_attribute"
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_attribute',
@level2type = N'COLUMN', @level2name = N'id_transformation_attribute';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Transformation Mapping",
    "fd" : "Reference to \"Transformation Mapping\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_attribute',
@level2type = N'COLUMN', @level2name = N'id_transformation_mapping';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Attribute",
    "fd" : "Reference to \"Attribute\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_attribute',
@level2type = N'COLUMN', @level2name = N'id_attribute';
GO
