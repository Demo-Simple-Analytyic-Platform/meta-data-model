CREATE TABLE tsa_dta.tsa_dataset (

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

);
GO