CREATE TABLE dta.transformation_column_mapping (

    /* Data Attributes */
    id_model                                CHAR(32)      NULL,
    id_attribute                            CHAR(32)      NULL,
    id_transformation_part                  CHAR(32)      NULL,
    id_transformation_column_mapping        CHAR(32)      NULL,
    tx_transformation_column_mapping        NVARCHAR(MAX) NULL,
    is_in_group_by                          BIT           NULL,
    
    
    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_transformation_mapping_pk PRIMARY KEY (meta_ch_pk),

);
GO