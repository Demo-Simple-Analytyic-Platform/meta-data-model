CREATE TABLE tsa_srd.tsa_processing_status (

    /* Data Attributes */
    id_model             CHAR(32)      NULL,
    id_processing_status CHAR(32)      NULL,
    ni_processing_status INT           NULL,
    fn_processing_status NVARCHAR(128) NULL,
    fd_processing_status NVARCHAR(999) NULL,

);
GO