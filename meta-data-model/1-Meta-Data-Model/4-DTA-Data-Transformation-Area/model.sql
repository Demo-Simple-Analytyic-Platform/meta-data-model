CREATE TABLE dta.model (

    /* Data Attributes */
    [id_model]         CHAR(32)      NULL,
    [nm_repository]    VARCHAR(128) NULL,
    
    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_model_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Model",
    "fd" : "Meta Data of the \"Model\".",
    "bk" : ["id_model"]
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'model';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Model",
    "fd" : "Unique Identiefier for dta.model"
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'model',
@level2type = N'COLUMN', @level2name = N'id_model';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Name of Model",
    "fd" : "Name of the Model, which also must corresponde with the name of the git repository.."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'model',
@level2type = N'COLUMN', @level2name = N'nm_repository';
GO
