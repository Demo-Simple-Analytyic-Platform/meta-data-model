CREATE TABLE tsa_dta.tsa_transformation_mapping (

    /* Data Attributes */
    id_model                                CHAR(32)      NULL,
    id_transformation_mapping               CHAR(32)      NULL,
    id_transformation_part                  CHAR(32)      NULL,
    id_attribute                            CHAR(32)      NULL,
    is_in_group_by                          BIT           NULL,
    tx_transformation_mapping               NVARCHAR(MAX) NULL,

);
GO