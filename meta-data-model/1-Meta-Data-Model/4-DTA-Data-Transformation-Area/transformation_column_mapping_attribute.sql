CREATE TABLE dta.transformation_column_mapping_attribute (

    /* Data Attributes */
    id_model                                   CHAR(32),
    id_transformation_column_mapping           CHAR(32),
    id_transformation_column_mapping_attribute CHAR(32),
    cd_source_alias                            NVARCHAR(32),
    id_source_model                            CHAR(32),
    id_source_attribute                        CHAR(32),
    tx_source_attribute                        NVARCHAR(MAX),

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_transformation_column_mapping_attribute_pk PRIMARY KEY (meta_ch_pk),

);
GO
