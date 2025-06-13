CREATE TABLE tsa_dta.tsa_schedule (

    /* Data Attributes */
    id_model                  CHAR(32)      NULL,
    id_dataset                CHAR(32)      NULL,
    id_schedule               CHAR(32)      NULL,
    is_ingestion              BIT           NULL, 
    cd_frequency              NVARCHAR(32)  NULL,
    ni_interval               INT           NULL,
    dt_start                  DATE          NULL,
    dt_end                    DATE          NULL,
    
);
GO