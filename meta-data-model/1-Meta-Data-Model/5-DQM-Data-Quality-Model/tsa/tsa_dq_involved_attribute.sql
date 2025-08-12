CREATE TABLE tsa_dqm.tsa_dq_involved_attribute (

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

);
GO