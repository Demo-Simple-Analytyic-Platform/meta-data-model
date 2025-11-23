CREATE TABLE tsa_dta.tsa_transformation_dataset_attribute (

    /* Data Attributes */
    id_model                                CHAR(32)      NULL,
    id_transformation_dataset               CHAR(32)      NULL,
    id_transformation_dataset_attribute     CHAR(32)      NULL,
    cd_source_alias                         NVARCHAR(32)  NULL,
    id_source_model                         CHAR(32)      NULL,
    id_source_attribute                     CHAR(32)      NULL,
    tx_source_attribute                     NVARCHAR(MAX) NULL,

);
GO