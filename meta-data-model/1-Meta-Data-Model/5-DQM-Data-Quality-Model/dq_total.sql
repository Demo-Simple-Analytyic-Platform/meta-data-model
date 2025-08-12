CREATE TABLE dqm.dq_total (

    /* Data dq_requirements */
    id_model                  CHAR(32)  NULL,
    id_dq_control             CHAR(32)  NULL,
    dt_dq_result              DATE      NULL, 
    id_dq_risk_level          CHAR(32)  NULL,
    ni_total                  INT       NULL,
    ni_oke                    INT       NULL,
    pr_oke                    DEC(24,6) NULL,
    ni_nok                    INT       NULL,
    pr_nok                    DEC(24,6) NULL,
    ni_oos                    INT       NULL,
    pr_oos                    DEC(24,6) NULL,
    
    /* Metadata dq_requirements */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dqm_dq_total_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Totals",
    "fd" : "The Aggregate/count per \"DQ Control\", \"Result Status\" en \"Review Status\".",
    "bk" : ["id_model", "id_dq_control", "dt_dq_result", "id_dq_risk_level"]
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_total';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Resutl Date",
    "fd" : "Date for the \"Totals\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_total',
@level2type = N'COLUMN', @level2name = N'dt_dq_result';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID DQ Control",
    "fd" : "Reference to \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_total',
@level2type = N'COLUMN', @level2name = N'id_dq_control';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID DQ Risk Level",
    "fd" : "Reference to \"DQ Result Status\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_total',
@level2type = N'COLUMN', @level2name = N'id_dq_risk_level';
GO

EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "# Total",
    "fd" : "The \"Total\" number of \"Records\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_total',
@level2type = N'COLUMN', @level2name = N'ni_total';
GO

EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "# Compliant",
    "fd" : "The \"Compliant\" (Compliant) number of \"Records\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_total',
@level2type = N'COLUMN', @level2name = N'ni_oke';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "% Compliant",
    "fd" : "The \"Compliant\" percentage of \"Records\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_total',
@level2type = N'COLUMN', @level2name = N'pr_oke';
GO

EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "# Exception",
    "fd" : "The \"Not Oke\" number of \"Records\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_total',
@level2type = N'COLUMN', @level2name = N'ni_nok';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "% Exception",
    "fd" : "The \"Not Oke\" percentage of \"Records\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_total',
@level2type = N'COLUMN', @level2name = N'pr_nok';
GO

EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "# Out of Scope",
    "fd" : "The \"Ou\" number of \"Records\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_total',
@level2type = N'COLUMN', @level2name = N'ni_oos';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "% Out of Scope",
    "fd" : "The \"Out of Scope\" percentage of \"Records\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_total',
@level2type = N'COLUMN', @level2name = N'pr_oos';
GO
