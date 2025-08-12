CREATE TABLE dqm.dq_involved_attribute (

    /* Data dq_requirements */
    id_model                  CHAR(32) NULL,
    id_dq_involved_attribute  CHAR(32) NULL,
    id_dq_control             CHAR(32) NULL,
    id_attribute              CHAR(32) NULL,
    is_used_for_result        BIT      NULL,
    is_used_for_scope         BIT      NULL,
    is_user_in_join_criteria  BIT      NULL,
    is_user_where             BIT      NULL,
    is_used_in_having         BIT      NULL,

    /* Metadata dq_requirements */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_dq_involved_attribute_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "DQ Involved Attribute",
    "fd" : "List of \"Involved Attributes\" of a \"DQ Control\", information about how the \"Attributes\" are used within the \"DQ Control\".",
    "bk" : ["id_model", "id_dq_control", "id_attribute"]
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_involved_attribute';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Data Quality Involved Attribute",
    "fd" : "Unique Identiefier for dqm.dq_involved_attribute"
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_involved_attribute',
@level2type = N'COLUMN', @level2name = N'id_dq_involved_attribute';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID DQ Control",
    "fd" : "Reference to \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_involved_attribute',
@level2type = N'COLUMN', @level2name = N'id_dq_control';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Attribute",
    "fd" : "Reference to \"Attribute\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_involved_attribute',
@level2type = N'COLUMN', @level2name = N'id_attribute';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Is used for Result",
    "fd" : "This \"Indicator\" if the \"Attribute\" is directly used to calculate the \"Result\" of the \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_involved_attribute',
@level2type = N'COLUMN', @level2name = N'is_used_for_result';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Is used for Scope",
    "fd" : "This \"Indicator\" if the \"Attribute\" is directly used to determine the \"Scope\" of the \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_involved_attribute',
@level2type = N'COLUMN', @level2name = N'is_used_for_scope';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Is used in join Criteria",
    "fd" : "This \"Indicator\" if the \"Attribute\" is directly used in the \"JOIN Criteria\" of the used \"Datasets\" of the  \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_involved_attribute',
@level2type = N'COLUMN', @level2name = N'is_user_in_join_criteria';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Is used in WHERE",
    "fd" : "This \"Indicator\" if the \"Attribute\" is directly used in the \"WHERE\"-clause of the \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_involved_attribute',
@level2type = N'COLUMN', @level2name = N'is_user_where';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Is used in HAVING",
    "fd" : "This \"Indicator\" if the \"Attribute\" is directly used in the \"HAVING\"-clause of the \"DQ Control\"."
}',
@level0type = N'SCHEMA', @level0name = N'dqm',
@level1type = N'TABLE',  @level1name = N'dq_involved_attribute',
@level2type = N'COLUMN', @level2name = N'is_used_in_having';
GO