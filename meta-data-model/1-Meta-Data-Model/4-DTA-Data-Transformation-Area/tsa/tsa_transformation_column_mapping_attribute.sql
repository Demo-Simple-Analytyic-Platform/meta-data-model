CREATE TABLE tsa_dta.tsa_transformation_column_mapping_attribute (

    /* Data Attributes */
    id_model                                   CHAR(32),
    id_transformation_column_mapping           CHAR(32),
    id_transformation_column_mapping_attribute CHAR(32),
    cd_source_alias                            NVARCHAR(32),
    id_source_model                            CHAR(32),
    id_source_attribute                        CHAR(32),
    tx_source_attribute                        NVARCHAR(MAX),

);
GO
