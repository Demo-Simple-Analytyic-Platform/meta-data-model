CREATE TABLE dta.ingestion_etl (

    /* Data Attributes */
    id_model                      CHAR(32)      NULL,
    id_ingestion_etl              CHAR(32)      NULL,
    id_dataset                    CHAR(32)      NULL,
    nm_processing_type            NVARCHAR(128) NULL,
    tx_sql_for_meta_dt_valid_from NVARCHAR(MAX) NULL,
    tx_sql_for_meta_dt_valid_till NVARCHAR(MAX) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_ingestion_etl_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "SQL for meta-Attributes",
    "fd" : "This the \"SQL\" for the \"meta\"-attribute of dt_valid_from and dt_valid_till are describes. This is then used in generation the cortrect \"SQL\" to update the database-table. NOTE: This only applicable for \"Ingestion\"-datasets.",
    "bk" : ["id_model", "id_dataset"]
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'ingestion_etl';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Parameter Value",
    "fd" : "Unique Identiefier for dta.parameter_value"
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'ingestion_etl',
@level2type = N'COLUMN', @level2name = N'id_ingestion_etl';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset",
    "fd" : "Reference to \"Dataset\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'ingestion_etl',
@level2type = N'COLUMN', @level2name = N'id_dataset';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Processing Type",
    "fd" : "The \"Processing Type\" this can be \"Incremental\" or \"Fullload\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'ingestion_etl',
@level2type = N'COLUMN', @level2name = N'nm_processing_type';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "SQL for meta_dt_valid_from",
    "fd" : "The \"SQL\" for \"meta_dt_valid_from\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'ingestion_etl',
@level2type = N'COLUMN', @level2name = N'tx_sql_for_meta_dt_valid_from';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "SQL for meta_dt_valid_till",
    "fd" : "The \"SQL\" for \"meta_dt_valid_till\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'ingestion_etl',
@level2type = N'COLUMN', @level2name = N'tx_sql_for_meta_dt_valid_till';
GO