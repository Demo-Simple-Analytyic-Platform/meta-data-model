CREATE TABLE tsa_dta.tsa_transformation_mapping (

    /* Data Attributes */
    id_model                                CHAR(32)      NULL,
    id_attribute                            CHAR(32)      NULL,
    id_transformation_part                  CHAR(32)      NULL,
    id_transformation_column_mapping        CHAR(32)      NULL,
    tx_transformation_column_mapping        NVARCHAR(MAX) NULL,
    is_in_group_by                          BIT           NULL,

);
GO