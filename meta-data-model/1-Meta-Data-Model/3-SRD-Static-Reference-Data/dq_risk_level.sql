CREATE TABLE srd.dq_risk_level (

    /* Data Attributes */
    id_model         CHAR(32)      NULL,
    id_dq_risk_level CHAR(32)      NULL,
    cd_dq_risk_level NVARCHAR(32)  NULL,
    fn_dq_risk_level NVARCHAR(128) NULL,
    fd_dq_risk_level NVARCHAR(999) NULL,
    cd_dq_status     NVARCHAR(32)  NULL,
    fn_dq_status     NVARCHAR(128) NULL,
    fd_dq_status     NVARCHAR(999) NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT srd_dq_risk_level_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Risk Level",
    "fd" : "DQ Risk Level is a metric for the level of risk the Business is exposed to in relation to the measured Data Quality (DQ). This level of risk correlates to the Status of the Data Quality being measured.",
    "bk" : ["id_model", "cd_dq_risk_level"]
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'dq_risk_level';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID DQ Risk Level",
    "fd" : "Unique Identiefier for srd.dq_risk_level"
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'dq_risk_level',
@level2type = N'COLUMN', @level2name = N'id_dq_risk_level';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Risk Level Code",
    "fd" : "The \"Code\" of the \"DQ Risk Level\" is singel character."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'dq_risk_level',
@level2type = N'COLUMN', @level2name = N'cd_dq_risk_level';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Risk Level Name",
    "fd" : "The \"Functional Name\" of the \"DQ Risk Level\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'dq_risk_level',
@level2type = N'COLUMN', @level2name = N'fn_dq_risk_level';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Risk Level Description",
    "fd" : "The \"Functional Description\" of the \"DQ Risk Level\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'dq_risk_level',
@level2type = N'COLUMN', @level2name = N'fd_dq_risk_level';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Status Code",
    "fd" : "The \"Code\" of the \"DQ Status\" is singel character."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'dq_risk_level',
@level2type = N'COLUMN', @level2name = N'cd_dq_status';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Status Name",
    "fd" : "The \"Functional Name\" of the \"DQ Status\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'dq_risk_level',
@level2type = N'COLUMN', @level2name = N'fn_dq_status';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Status Description",
    "fd" : "The \"Functional Description\" of the \"DQ Status\"."
}',
@level0type = N'SCHEMA', @level0name = N'srd',
@level1type = N'TABLE',  @level1name = N'dq_risk_level',
@level2type = N'COLUMN', @level2name = N'fd_dq_status';
GO