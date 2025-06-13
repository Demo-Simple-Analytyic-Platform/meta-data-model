CREATE TABLE tsa_srd.tsa_processing_step (

    /* Data Attributes */
    id_model           CHAR(32)      NULL,
    id_processing_step CHAR(32)      NULL,
    ni_processing_step INT           NULL,
    fn_processing_step NVARCHAR(128) NULL,
    fd_processing_step NVARCHAR(999) NULL,

);
GO