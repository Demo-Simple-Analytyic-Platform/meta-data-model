CREATE TABLE tsa_srd.tsa_parameter (

    /* Data Attributes */
    id_model           CHAR(32)      NULL,
    id_parameter       CHAR(32)      NULL,
    id_parameter_group CHAR(32)      NULL,
    nm_parameter       NVARCHAR(32)  NULL,
    fn_parameter       NVARCHAR(128) NULL,
    fd_parameter       NVARCHAR(999) NULL,

);
GO