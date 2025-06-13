CREATE TABLE dta.dataset (

    /* Data Attributes */
    id_model                  CHAR(32)      NULL,
    id_dataset                CHAR(32)      NULL,
    id_development_status     CHAR(32)      NULL,
    id_group                  CHAR(32)      NULL,
    is_ingestion              BIT           NULL, 
    fn_dataset                NVARCHAR(128) NULL,
    fd_dataset                NVARCHAR(MAX) NULL,
    nm_target_schema          NVARCHAR(128) NULL,
    nm_target_table           NVARCHAR(128) NULL,
    tx_source_query           NVARCHAR(MAX) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_dataset_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Dataset",
    "fd" : "Meta Data of the \"Dataset\".",
    "bk" : ["id_model", "nm_target_schema", "nm_target_table"]
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'dataset';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset",
    "fd" : "Unique Identiefier for dta.dataset"
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'dataset',
@level2type = N'COLUMN', @level2name = N'id_dataset';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Group",
    "fd" : "Reference to \"Group\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'dataset',
@level2type = N'COLUMN', @level2name = N'id_group';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Is Ingestion",
    "fd" : "Indication if \"Dataset\" is \"Ingestion\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'dataset',
@level2type = N'COLUMN', @level2name = N'is_ingestion';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Name (Dataset)",
    "fd" : "The \"Functional Name\" of the \"Dataset\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'dataset',
@level2type = N'COLUMN', @level2name = N'fn_dataset';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Description (Dataset)",
    "fd" : "The \"Functional Description\" of the \"Dataset\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'dataset',
@level2type = N'COLUMN', @level2name = N'fd_dataset';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Target Schema Name",
    "fd" : "The \"Name\" of the \"Target Schema\" where \"Dataset\" would be created."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'dataset',
@level2type = N'COLUMN', @level2name = N'nm_target_schema';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Target Schema Name",
    "fd" : "The \"Name\" of the \"Target Table\" that would be created."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'dataset',
@level2type = N'COLUMN', @level2name = N'nm_target_table';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Text Source Query",
    "fd" : "The \"Text\" of the \"Source Query\" for an \"Ingestion\"-dataset there should be \"Parameters\" provided to be used in a "Data Factory"-tool. For a NON-ingestion \"dataset\" there should be a \"SELECT\"-query utilizing \"Dataset(s)\". Sub-Query are NOT allowed, all utilized dataset must have an Alias the same voor all the \"output\"-columns. For the \"column\"-mapping classic SQL column-aliasses should be used."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'dataset',
@level2type = N'COLUMN', @level2name = N'tx_source_query';
GO