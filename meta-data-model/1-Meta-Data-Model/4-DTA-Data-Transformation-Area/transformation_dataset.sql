CREATE TABLE dta.transformation_dataset (

    /* Data Attributes */
    id_model                                CHAR(32)      NULL,
    id_transformation_part                  CHAR(32)      NULL,
    id_transformation_dataset               CHAR(32)      NULL,
    ni_transformation_dataset               INT           NULL,
    cd_join_type                            NVARCHAR(32)  NULL,
    id_source_model                         CHAR(32)      NULL,
    id_dataset                              CHAR(32)      NULL,
    cd_alias                                NVARCHAR(32)  NULL,
    tx_join_criteria                        NVARCHAR(MAX) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_transformation_dataset_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Transformation (Utilized) Dataset",
    "fd" : "Utilized \"Dataset(s)\" of a \"Transformation Part\" with its join type, reference to \"Dataset\", alias and join criteria.",
    "bk" : ["id_model", "id_transformation_part", "id_dataset", "cd_alias"]
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_dataset';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Transformation Dataset",
    "fd" : "Unique Identiefier for dta.transformation_dataset"
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_dataset',
@level2type = N'COLUMN', @level2name = N'id_transformation_dataset';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Transformation Part",
    "fd" : "Reference to \"Transformation Part\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_dataset',
@level2type = N'COLUMN', @level2name = N'id_transformation_part';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Join Type Code",
    "fd" : "The \"Join Type\", allowed values are \"FROM, JOIN, LEFT JOIN and CROSS JOIN\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_dataset',
@level2type = N'COLUMN', @level2name = N'cd_join_type';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset",
    "fd" : "Reference to \"Dataset\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_dataset',
@level2type = N'COLUMN', @level2name = N'id_dataset';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Alias Code",
    "fd" : "Code for \"Alias\" of the utilized \"Dataset\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_dataset',
@level2type = N'COLUMN', @level2name = N'cd_alias';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Text (SQL) Join Criteria",
    "fd" : "The \"SQL\"-text of \"Join Criteria\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'transformation_dataset',
@level2type = N'COLUMN', @level2name = N'tx_join_criteria';
GO