CREATE TABLE tsa_srd.tsa_datatype (

    /* Data Attributes */
    id_model                  CHAR(32)      NULL,
    id_datatype               CHAR(32)      NULL,
    fn_datatype               NVARCHAR(128) NULL,
    fd_datatype               NVARCHAR(999) NULL,
    cd_target_datatype        NVARCHAR(32)  NULL,
    cd_prefix_column_name     NVARCHAR(32)  NULL,
    cd_symbol_functional_naam NVARCHAR(32)  NULL,
    
);
GO
GO