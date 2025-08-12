CREATE TABLE dqm.dq_control (

    /* Data dq_requirements */
    id_model                  CHAR(32)      NULL,
    id_dq_control             CHAR(32)      NULL,
    id_development_status     CHAR(32)      NULL,
    id_dq_requirement         CHAR(32)      NULL,
    id_dq_dimension           CHAR(32)      NULL,
    id_dataset                CHAR(32)      NULL,
    cd_dq_control             NVARCHAR(32)  NULL,
    fn_dq_control             NVARCHAR(128) NULL,
    fd_dq_control             NVARCHAR(999) NULL,
    tx_dq_control_query       NVARCHAR(MAX) NULL,
    dt_valid_from             DATE          NULL,
    dt_valid_till             DATE          NULL,

    /* Metadata dq_requirements */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dqm_dq_control_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "dq_requirements",
    "fd" : "List of \"dq_requirements\" of a \"Dataset\".",
    "bk" : ["id_model", "id_dq_requirement", "id_dataset", "cd_dq_control"]
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_control';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Data Quality Control",
    "fd" : "Unique Identiefier for dqm.dq_control"
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_control',
@level2type = N'COLUMN', @level2name = N'id_dq_control';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID DQ Requirement",
    "fd" : "Reference to \"DQ Requirement\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_control',
@level2type = N'COLUMN', @level2name = N'id_dq_requirement';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID DQ Dimension",
    "fd" : "Reference to \"DQ Dimension\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_control',
@level2type = N'COLUMN', @level2name = N'id_dq_dimension';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset",
    "fd" : "Reference to \"Dataset\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_control',
@level2type = N'COLUMN', @level2name = N'id_dataset';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Control Code",
    "fd" : "The \"Code\" of the \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_control',
@level2type = N'COLUMN', @level2name = N'cd_dq_control';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Name (DQ Control)",
    "fd" : "The \"Functional Name\" of the \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_control',
@level2type = N'COLUMN', @level2name = N'fn_dq_control';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Description (DQ Control)",
    "fd" : "The \"Functional Description\" of the \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_control',
@level2type = N'COLUMN', @level2name = N'fd_dq_control';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Valid From Date",
    "fd" : "The \"Valid\"-from of the \"DQ Requirement\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_control',
@level2type = N'COLUMN', @level2name = N'dt_valid_from';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Valid Till Date",
    "fd" : "The \"Valid Till\" of the \"DQ Requirement\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_control',
@level2type = N'COLUMN', @level2name = N'dt_valid_till';
GO