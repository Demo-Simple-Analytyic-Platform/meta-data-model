CREATE TABLE srd.processing_status (

    /* Data Attributes */
    id_model             CHAR(32)      NULL,
    id_processing_status CHAR(32)      NULL,
    ni_processing_status INT           NULL,
    fn_processing_status NVARCHAR(128) NULL,
    fd_processing_status NVARCHAR(999) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT srd_processing_status_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Processing Status",
    "fd" : "List of \"Processing Statusses\" of the \"Data (Quality) Procesing\"-steps.",
    "bk" : ["id_model", "cd_processing_status"]
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'processing_status';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Processing Status",
    "fd" : "Unique Identiefier for srd.processing_status"
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'processing_status',
@level2type = N'COLUMN', @level2name = N'id_processing_status';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Processing Status Order",
    "fd" : "The \"Processing Statusses\" have a order in which they can occur."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'processing_status',
@level2type = N'COLUMN', @level2name = N'ni_processing_status';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Processing Status Name",
    "fd" : "The \"Functional Name\" of the \"Processing Status\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'processing_status',
@level2type = N'COLUMN', @level2name = N'fn_processing_status';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Processing Status Order",
    "fd" : "The \"Functional Description\" of the \"Processing Status\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'processing_status',
@level2type = N'COLUMN', @level2name = N'fd_processing_status';
GO