CREATE TABLE dqm.dq_review (

    /* Data dq_requirements */
    id_model                  CHAR(32)      NULL,
    id_dq_review              CHAR(32)      NULL,
    id_dq_result              CHAR(32)      NULL,
    id_dq_review_status       CHAR(32)      NULL,
    dt_reviewed_at            DATE          NULL,
    nm_reviewed_by            NVARCHAR(128) NULL,
    tx_reviewed_report        NVARCHAR(MAX) NULL,
    dt_validated_at           DATE          NULL,
    nm_validated_by           NVARCHAR(128) NULL,
    tx_validated_report       NVARCHAR(MAX) NULL,
    
    /* Metadata dq_requirements */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dqm_dq_review_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Review",
    "fd" : "Review information about \"DQ Result\".",
    "bk" : ["id_model", "id_dq_result"]
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_review';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Data Quality Review",
    "fd" : "Unique Identiefier for dqm.dq_review"
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_review',
@level2type = N'COLUMN', @level2name = N'id_dq_review';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID DQ Result",
    "fd" : "Reference to \"DQ Result\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_review',
@level2type = N'COLUMN', @level2name = N'id_dq_result';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID DQ Review Status",
    "fd" : "Reference to \"DQ Review Status\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_review',
@level2type = N'COLUMN', @level2name = N'id_dq_review_status';
GO

EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Review Date",
    "fd" : "The \"Date\" of the \"Review\" (Status) that was set for the \"DQ Result\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_review',
@level2type = N'COLUMN', @level2name = N'dt_reviewed_at';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Review By",
    "fd" : "The \"User\" to which then \"Review\" (Status) applies."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_review',
@level2type = N'COLUMN', @level2name = N'nm_reviewed_by';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Review Report",
    "fd" : "The \"Text\" of the \"Review\", this should be a short \"Report\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_review',
@level2type = N'COLUMN', @level2name = N'tx_reviewed_report';
GO

EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Validate Date",
    "fd" : "The \"Date\" of the \"Validate\" (Status) that was set for the \"DQ Result\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_review',
@level2type = N'COLUMN', @level2name = N'dt_validated_at';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Validate By",
    "fd" : "The \"User\" to which then \"Validate\" (Status) applies."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_review',
@level2type = N'COLUMN', @level2name = N'nm_validated_by';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Validate Report",
    "fd" : "The \"Text\" of the \"Validate\", this should be a short \"Report\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_review',
@level2type = N'COLUMN', @level2name = N'tx_validated_report';
GO
GO