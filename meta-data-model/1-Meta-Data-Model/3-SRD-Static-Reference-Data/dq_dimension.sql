CREATE TABLE srd.dq_dimension (

    /* Data Attributes */
    id_model        CHAR(32)      NULL,
    id_dq_dimension CHAR(32)      NULL,
    fn_dq_dimension NVARCHAR(128) NULL,
    fd_dq_dimension NVARCHAR(999) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT srd_dq_dimension_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Dimension",
    "fd" : "List of DQ Dimensions, see DAMA framework for a good reference.",
    "bk" : ["id_model", "fn_dq_dimension"]
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'dq_dimension';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID DQ Dimension",
    "fd" : "Unique Identiefier for srd.dq_dimension"
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'dq_dimension',
@level2type = N'COLUMN', @level2name = N'id_dq_dimension';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Name (DQ Dimension)",
    "fd" : "The \"Functional Name\" of the \"DQ Dimension\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'dq_dimension',
@level2type = N'COLUMN', @level2name = N'fn_dq_dimension';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Description (DQ Dimension)",
    "fd" : "The \"Functional Description\" of the \"DQ Dimension\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'dq_dimension',
@level2type = N'COLUMN', @level2name = N'fd_dq_dimension';
GO