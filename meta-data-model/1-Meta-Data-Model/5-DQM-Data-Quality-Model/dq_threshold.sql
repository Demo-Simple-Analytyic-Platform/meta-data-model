CREATE TABLE dqm.dq_threshold (

    /* Data dq_requirements */
    id_model                  CHAR(32)  NULL,
    id_dq_threshold           CHAR(32)  NULL,
    id_dq_control             CHAR(32)  NULL,
    id_dq_risk_level          CHAR(32)  NULL,
    nr_dq_threshold_from      DEC(24,6) NULL,
    nr_dq_threshold_till      DEC(24,6) NULL,
    dt_valid_from             DATE      NULL,
    dt_valid_till             DATE      NULL,

    /* Metadata dq_requirements */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dqm_dq_threshold_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Threshold",
    "fd" : "List of \"Thresholds\" of a \"DQ Control\".",
    "bk" : ["id_model", "id_dq_control", "id_dq_risk_level", "nr_dq_threshold_from"]
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_threshold';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Data Quality Threshold",
    "fd" : "Unique Identiefier for dqm.dq_threshold"
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_threshold',
@level2type = N'COLUMN', @level2name = N'id_dq_threshold';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID DQ Control",
    "fd" : "Reference to \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_threshold',
@level2type = N'COLUMN', @level2name = N'id_dq_control';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID DQ Risk Level",
    "fd" : "Reference to \"DQ Risk Level\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_threshold',
@level2type = N'COLUMN', @level2name = N'id_dq_risk_level';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "% Threshold Level From",
    "fd" : "The \"Threshold Level\"-from of the \"DQ Control\" for referenced \"Risk Level\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_threshold',
@level2type = N'COLUMN', @level2name = N'nr_dq_threshold_from';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "% Threshold Level Till",
    "fd" : "The \"Threshold Level\"-till of the \"DQ Control\" for referenced \"Risk Level\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_threshold',
@level2type = N'COLUMN', @level2name = N'nr_dq_threshold_till';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Valid From Date",
    "fd" : "The \"Valid\"-from of the \"DQ Requirement\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_threshold',
@level2type = N'COLUMN', @level2name = N'dt_valid_from';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Valid Till Date",
    "fd" : "The \"Valid Till\" of the \"DQ Requirement\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_threshold',
@level2type = N'COLUMN', @level2name = N'dt_valid_till';
GO