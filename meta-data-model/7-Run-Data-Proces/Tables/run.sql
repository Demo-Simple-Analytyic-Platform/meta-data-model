CREATE TABLE rdp.run (

    /* Data dq_requirements */
    id_model                  CHAR(32)          NULL,
    id_run                    CHAR(32)      NOT NULL,
    id_dataset                CHAR(32)      NOT NULL DEFAULT 'n/a',
    id_dq_control             CHAR(32)      NOT NULL DEFAULT 'n/a',
    id_processing_status      CHAR(32)      NOT NULL,
    ds_external_reference_id  NVARCHAR(999)     NULL,
    dt_previous_stand         DATETIME      NOT NULL,
    dt_current_stand          DATETIME      NOT NULL,
    ni_previous_epoch         INT           NOT NULL,
    ni_current_epoch          INT           NOT NULL,
    dt_run_started            DATETIME      NOT NULL,
    dt_run_finished           DATETIME          NULL,

    ni_before                 INT               NULL,
    ni_ingested               INT               NULL,
    ni_inserted               INT               NULL,
    ni_updated                INT               NULL,
    ni_after                  INT               NULL,
    
    tx_message                NVARCHAR(4000)    NULL, 

    /* Primarykey */
    CONSTRAINT dqm_run_pk PRIMARY KEY (id_run),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Run Data Quality",
    "fd" : "Run Data Quality Processing information.",
    "bk" : ["id_dataset", "dt_run_started"]
}',
@level0type = N'SCHEMA', @level0name = N'rdp',
@level1type = N'TABLE',  @level1name = N'run';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Run Data Quality",
    "fd" : "Unique Identiefier for rdp.run"
}',
@level0type = N'SCHEMA', @level0name = N'rdp',
@level1type = N'TABLE',  @level1name = N'run',
@level2type = N'COLUMN', @level2name = N'id_run';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Data Quality",
    "fd" : "Reference to \"Data Quality Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'rdp',
@level1type = N'TABLE',  @level1name = N'run',
@level2type = N'COLUMN', @level2name = N'id_dq_control';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Processing Status",
    "fd" : "Reference to \"Processing Status\"."
}',
@level0type = N'SCHEMA', @level0name = N'rdp',
@level1type = N'TABLE',  @level1name = N'run',
@level2type = N'COLUMN', @level2name = N'id_processing_status';
GO

EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "External Reference ID",
    "fd" : "A \"Externa Reference ID\" to link to a "External"-processes that may be used to orchitrate de processing of datasets."
}',
@level0type = N'SCHEMA', @level0name = N'rdp',
@level1type = N'TABLE',  @level1name = N'run',
@level2type = N'COLUMN', @level2name = N'ds_external_reference_id';
GO

EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Previous Stand",
    "fd" : "The \"Previous\"-stand that was used in the previous \"Run\"."
}',
@level0type = N'SCHEMA', @level0name = N'rdp',
@level1type = N'TABLE',  @level1name = N'run',
@level2type = N'COLUMN', @level2name = N'dt_previous_stand';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Current Stand",
    "fd" : "The \"Current\"-stand which the \"Run\" is using."
}',
@level0type = N'SCHEMA', @level0name = N'rdp',
@level1type = N'TABLE',  @level1name = N'run',
@level2type = N'COLUMN', @level2name = N'dt_current_stand';
GO

EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Run Started",
    "fd" : "The \"Start\"-moment of the \"Run\"."
}',
@level0type = N'SCHEMA', @level0name = N'rdp',
@level1type = N'TABLE',  @level1name = N'run',
@level2type = N'COLUMN', @level2name = N'dt_run_started';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Run Finished",
    "fd" : "The \"Finished\"-moment of the \"Run\"."
}',
@level0type = N'SCHEMA', @level0name = N'rdp',
@level1type = N'TABLE',  @level1name = N'run',
@level2type = N'COLUMN', @level2name = N'dt_run_finished';
GO
