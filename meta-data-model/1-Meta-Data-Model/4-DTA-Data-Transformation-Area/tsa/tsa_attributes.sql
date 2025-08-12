CREATE TABLE tsa_dta.tsa_attribute (

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

);
GO