CREATE TABLE srd.processing_step (

    /* Data Attributes */
    id_model           CHAR(32)      NULL,
    id_processing_step CHAR(32)      NULL,
    ni_processing_step INT           NULL,
    fn_processing_step NVARCHAR(128) NULL,
    fd_processing_step NVARCHAR(999) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT srd_processing_step_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Processing Steps",
    "fd" : "The \"Processing Steps\" are the \"Descriptions\" of \"Steps\" to "Data (Qualityty) Processing" of \"Datase"\".",
    "bk" : ["id_model", "cd_processing_step"]
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'processing_step';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Processing Step",
    "fd" : "Unique Identiefier for srd.processing_step"
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'processing_step',
@level2type = N'COLUMN', @level2name = N'id_processing_step';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Processing Status Order",
    "fd" : "The \"Processing Statusses\" have a order in which they can occur."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'processing_step',
@level2type = N'COLUMN', @level2name = N'ni_processing_step';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Processing Status Name",
    "fd" : "The \"Functional Name\" of the \"Processing Status\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'processing_step',
@level2type = N'COLUMN', @level2name = N'fn_processing_step';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Processing Status Order",
    "fd" : "The \"Functional Description\" of the \"Processing Status\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'processing_step',
@level2type = N'COLUMN', @level2name = N'fd_processing_step';
GO