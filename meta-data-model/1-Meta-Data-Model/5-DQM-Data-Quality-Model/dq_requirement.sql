CREATE TABLE dqm.dq_requirement (

    /* Data dq_requirements */
    id_model                  CHAR(32)      NULL,
    id_dq_requirement         CHAR(32)      NULL,
    id_development_status     CHAR(32)      NULL,
    cd_dq_requirement         NVARCHAR(32)  NULL,
    fn_dq_requirement         NVARCHAR(128) NULL,
    fd_dq_requirement         NVARCHAR(999) NULL,
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
    CONSTRAINT dqm_dq_requirement_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Requirements",
    "fd" : "List of \"DQ Requirements\".",
    "bk" : ["id_model", "id_dq_dimension", "cd_dq_requirement"]
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_requirement';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Data Quality Requirement",
    "fd" : "Unique Identiefier for dqm.dq_requirement"
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_requirement',
@level2type = N'COLUMN', @level2name = N'id_dq_requirement';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Requirement Code",
    "fd" : "Reference to \"DQ Requirement\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_requirement',
@level2type = N'COLUMN', @level2name = N'cd_dq_requirement';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Name (DQ Requirement)",
    "fd" : "The \"Functional Name\" of the \"DQ Requirement\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_requirement',
@level2type = N'COLUMN', @level2name = N'fn_dq_requirement';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Functional Description (DQ Requirement)",
    "fd" : "The \"Functional Description\" of the \"DQ Requirement\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_requirement',
@level2type = N'COLUMN', @level2name = N'fd_dq_requirement';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Valid From Date",
    "fd" : "The \"Valid\"-from of the \"DQ Requirement\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_requirement',
@level2type = N'COLUMN', @level2name = N'dt_valid_from';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Valid Till Date",
    "fd" : "The \"Valid Till\" of the \"DQ Requirement\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_requirement',
@level2type = N'COLUMN', @level2name = N'dt_valid_till';
GO