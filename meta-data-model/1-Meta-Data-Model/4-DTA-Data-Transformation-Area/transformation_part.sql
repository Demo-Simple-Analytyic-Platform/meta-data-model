CREATE TABLE dta.transformation_part (

    /* Data Attributes */
    id_model                               CHAR(32)      NULL,
    id_dataset                             CHAR(32)      NULL,
    id_transformation_part                 CHAR(32)      NULL,
    ni_transformation_part                 INT           NULL,
    tx_transformation_part                 NVARCHAR(MAX) NULL,
    tx_transformation_part_where_clause    NVARCHAR(MAX) NULL,
    tx_transformation_part_group_by_clause NVARCHAR(MAX) NULL,
    tx_transformation_part_having_clause   NVARCHAR(MAX) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_transformation_part_pk PRIMARY KEY (meta_ch_pk),
    
);
GO