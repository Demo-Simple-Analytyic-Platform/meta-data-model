CREATE TABLE dta.transformation_part_attribute (

    /* Data Attributes */
    id_model                            CHAR(32)      NULL,
    id_transformation_part              CHAR(32)      NULL,
    id_transformation_part_attribute    CHAR(32)      NULL,
    cd_transformation_part_clause_type  NVARCHAR(32)  NULL,
    cd_source_alias                     NVARCHAR(32)  NULL,
    id_source_model                     CHAR(32)      NULL,
    id_source_attribute                 CHAR(32)      NULL,
    tx_source_attribute                 NVARCHAR(MAX) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_transformation_part_attribute_pk PRIMARY KEY (meta_ch_pk),

);
GO
