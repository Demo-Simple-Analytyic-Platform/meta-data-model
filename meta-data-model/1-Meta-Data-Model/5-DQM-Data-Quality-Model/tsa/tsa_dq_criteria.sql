CREATE TABLE tsa_dqm.tsa_dq_criteria (

    /* Data dq_requirements */
    id_model                  CHAR(32)      NULL,
    id_dq_control             CHAR(32)      NULL,
    id_dq_result_status       CHAR(32)      NULL,
    id_dq_criteria            CHAR(32)      NULL,
    ni_dq_criteria            INT           NULL,
    tx_dq_criteria            NVARCHAR(MAX) NULL,
    
);
GO