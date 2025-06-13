CREATE TABLE tsa_dta.tsa_ingestion_etl (

    /* Data Attributes */
    id_model                      CHAR(32)      NULL,
    id_ingestion_etl              CHAR(32)      NULL,
    id_dataset                    CHAR(32)      NULL,
    nm_processing_type            NVARCHAR(128) NULL,
    tx_sql_for_meta_dt_valid_from NVARCHAR(MAX) NULL,
    tx_sql_for_meta_dt_valid_till NVARCHAR(MAX) NULL,

);
GO