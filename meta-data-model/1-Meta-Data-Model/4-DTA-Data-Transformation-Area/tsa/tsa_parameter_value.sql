CREATE TABLE tsa_dta.tsa_parameter_value (

    /* Data Attributes */
    id_model                  CHAR(32)      NULL,
    id_parameter_value        CHAR(32)      NULL,
    id_dataset                CHAR(32)      NULL,
    id_parameter              CHAR(32)      NULL,
    ni_parameter_value        INT           NULL,
    tx_parameter_value        NVARCHAR(MAX) NULL,
    
);
GO
GO