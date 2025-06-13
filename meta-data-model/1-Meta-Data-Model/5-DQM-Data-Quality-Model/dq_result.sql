CREATE TABLE dqm.dq_result (

    /* Data dq_requirements */
    id_model             CHAR(32) NULL,
    id_dq_control        CHAR(32) NULL,
    id_dataset_1_bk      CHAR(32) NULL,
    id_dataset_2_bk      CHAR(32) NULL,
    id_dataset_3_bk      CHAR(32) NULL,
    id_dataset_4_bk      CHAR(32) NULL,
    id_dataset_5_bk      CHAR(32) NULL,
    id_dq_result_status  CHAR(32) NULL,
    
    /* Metadata dq_requirements */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dqm_dq_result_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Threshold",
    "fd" : "List of \"Thresholds\" of a \"DQ Control\".",
    "bk" : ["id_model", "id_dq_control", "id_dataset_1_bk", "id_dataset_2_bk", "id_dataset_3_bk", "id_dataset_4_bk", "id_dataset_5_bk"]
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_result';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID DQ Control",
    "fd" : "Reference to \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_result',
@level2type = N'COLUMN', @level2name = N'id_dq_control';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID DQ Result Status",
    "fd" : "Reference to \"DQ Result Status\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_result',
@level2type = N'COLUMN', @level2name = N'id_dq_result_status';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset (meta_bk)",
    "fd" : "The \"Businesskey\"-value of the \"Record\" from the \"Dataset 1\" checked by the \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_result',
@level2type = N'COLUMN', @level2name = 'id_dataset_1_bk';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset (meta_bk)",
    "fd" : "The \"Businesskey\"-value of the \"Record\" from the \"Dataset 2\" checked by the \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_result',
@level2type = N'COLUMN', @level2name = 'id_dataset_2_bk';
GO

EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset (meta_bk)",
    "fd" : "The \"Businesskey\"-value of the \"Record\" from the \"Dataset 3\" checked by the \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_result',
@level2type = N'COLUMN', @level2name = 'id_dataset_3_bk';
GO

EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset (meta_bk)",
    "fd" : "The \"Businesskey\"-value of the \"Record\" from the \"Dataset 4\" checked by the \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_result',
@level2type = N'COLUMN', @level2name = 'id_dataset_4_bk';
GO

EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset (meta_bk)",
    "fd" : "The \"Businesskey\"-value of the \"Record\" from the \"Dataset 5\" checked by the \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_result',
@level2type = N'COLUMN', @level2name = 'id_dataset_5_bk';
GO