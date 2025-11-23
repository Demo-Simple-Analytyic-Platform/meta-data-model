CREATE TABLE tsa_dta.tsa_transformation_part (

    /* Data Attributes */
    id_model                               CHAR(32)      NULL,
    id_dataset                             CHAR(32)      NULL,
    id_transformation_part                 CHAR(32)      NULL,
    ni_transformation_part                 INT           NULL,
    tx_transformation_part                 NVARCHAR(MAX) NULL,
    tx_transformation_part_where_clause    NVARCHAR(MAX) NULL,
    tx_transformation_part_group_by_clause NVARCHAR(MAX) NULL,
    tx_transformation_part_having_clause   NVARCHAR(MAX) NULL,
    
);
GO
