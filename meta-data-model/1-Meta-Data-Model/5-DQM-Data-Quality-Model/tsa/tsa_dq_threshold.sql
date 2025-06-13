CREATE TABLE tsa_dqm.tsa_dq_threshold (

    /* Data dq_requirements */
    id_model                  CHAR(32)  NULL,
    id_dq_threshold           CHAR(32)  NULL,
    id_dq_control             CHAR(32)  NULL,
    id_dq_risk_level          CHAR(32)  NULL,
    nr_dq_threshold_from      DEC(24,6) NULL,
    nr_dq_threshold_till      DEC(24,6) NULL,
    dt_valid_from             DATE      NULL,
    dt_valid_till             DATE      NULL,

);
GO