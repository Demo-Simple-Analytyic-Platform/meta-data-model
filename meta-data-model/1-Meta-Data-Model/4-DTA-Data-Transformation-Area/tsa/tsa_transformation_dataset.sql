CREATE TABLE tsa_dta.tsa_transformation_dataset (

    /* Data Attributes */
    id_model                                CHAR(32)      NULL,
    id_transformation_part                  CHAR(32)      NULL,
    id_transformation_dataset               CHAR(32)      NULL,
    ni_transformation_dataset               INT           NULL,
    cd_join_type                            NVARCHAR(32)  NULL,
    id_source_model                         CHAR(32)      NULL,
    id_dataset                              CHAR(32)      NULL,
    cd_alias                                NVARCHAR(32)  NULL,
    tx_join_criteria                        NVARCHAR(MAX) NULL,
    
);
GO