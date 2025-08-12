CREATE TABLE dta.parameter_value (

    /* Data Attributes */
    id_model                  CHAR(32)      NULL,
    id_parameter_value        CHAR(32)      NULL,
    id_dataset                CHAR(32)      NULL,
    id_parameter              CHAR(32)      NULL,
    ni_parameter_value        INT           NULL,
    tx_parameter_value        NVARCHAR(MAX) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_parameter_value_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Parameter Value",
    "fd" : "List of \"Parameters\" of a \"Dataset\" with the \"Values\".",
    "bk" : ["id_model", "id_dataset", "fn_attribute"]
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'parameter_value';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Parameter Value",
    "fd" : "Unique Identiefier for dta.parameter_value"
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'parameter_value',
@level2type = N'COLUMN', @level2name = N'id_parameter_value';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset",
    "fd" : "Reference to \"Dataset\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'parameter_value',
@level2type = N'COLUMN', @level2name = N'id_dataset';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Parameter",
    "fd" : "Reference to \"Parameter\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'parameter_value',
@level2type = N'COLUMN', @level2name = N'id_parameter';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Parameter Value",
    "fd" : "The \"Value\" of the \"Parameter\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'parameter_value',
@level2type = N'COLUMN', @level2name = N'tx_parameter_value';
GO