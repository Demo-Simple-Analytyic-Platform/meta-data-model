CREATE TABLE dta.transformation_part (

    /* Data Attributes */
    id_model                             CHAR(32)      NULL,
    id_transformation_part               CHAR(32)      NULL,
    id_dataset                           CHAR(32)      NULL,
    ni_transformation_part               INT           NULL,
    tx_transformation_part               NVARCHAR(MAX) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_transformation_part_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Transformation Part",
    "fd" : "Individual parts of a Transformation that are separated by a \"UNION (ALL)\"-statement.",
    "bk" : ["id_model", "id_dataset", "ni_transformation_part"]
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_part';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Transformatin Part",
    "fd" : "Unique Identiefier for dta.transformation_part"
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_part',
@level2type = N'COLUMN', @level2name = N'id_transformation_part';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset",
    "fd" : "Reference to \"Dataset\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_part',
@level2type = N'COLUMN', @level2name = N'id_dataset';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "# Transformation Part",
    "fd" : "The \"part\" of the \"Transformation\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_part',
@level2type = N'COLUMN', @level2name = N'ni_transformation_part';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Transformation Part Text (SQL)",
    "fd" : "The \"SQL\"-text of the \"Transformation Part\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_part',
@level2type = N'COLUMN', @level2name = N'tx_transformation_part';
GO