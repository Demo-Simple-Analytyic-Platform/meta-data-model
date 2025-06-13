CREATE TABLE dqm.dq_criteria (

    /* Data dq_requirements */
    id_model                  CHAR(32)      NULL,
    id_dq_control             CHAR(32)      NULL,
    id_dq_result_status       CHAR(32)      NULL,
    id_dq_criteria            CHAR(32)      NULL,
    ni_dq_criteria            INT           NULL,
    tx_dq_criteria            NVARCHAR(MAX) NULL,

    /* Metadata dq_requirements */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dqm_dq_criteria_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Criteria",
    "fd" : "List of \"DQ Criteria\" of a \"DQ Control\" with the outcome of \"DQ Result Status\".". This infromation is extracted from the \"DQ Control\"-query defined by a Developer."
    "bk" : ["id_model", "id_dq_control", "id_dq_result_status", "ni_dq_criteria"]
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_criteria';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Data Quality Control",
    "fd" : "Reference to \"DQ Control\" for which this \"Criteria\" is part of."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_criteria',
@level2type = N'COLUMN', @level2name = N'id_dq_control';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Result Status",
    "fd" : "Reference to \"DQ Result Status\", this in outcome for this \"Criteria\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_criteria',
@level2type = N'COLUMN', @level2name = N'id_dq_result_status';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID DQ Criteria",
    "fd" : "Unique Identiefier for dqm.dq_criteria"
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_criteria',
@level2type = N'COLUMN', @level2name = N'id_dq_criteria';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "# DQ Criteria",
    "fd" : "The number/ordering of the \"DQ Criteria\" in which they were programmed."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_criteria',
@level2type = N'COLUMN', @level2name = N'ni_dq_criteria';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Criteria Text",
    "fd" : "The \"DQ Criteria\"-text is the \"SQL\"-code that is used to validate the \"DQ Criteria\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_criteria',
@level2type = N'COLUMN', @level2name = N'tx_dq_criteria';
GO