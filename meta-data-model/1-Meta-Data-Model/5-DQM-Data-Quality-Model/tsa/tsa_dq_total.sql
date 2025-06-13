CREATE TABLE tsa_dqm.tsa_dq_total (

    /* Data dq_requirements */
    id_model                  CHAR(32)  NULL,
    id_dq_control             CHAR(32)  NULL,
    dt_dq_result              DATE      NULL, 
    id_dq_risk_level          CHAR(32)  NULL,
    ni_total                  INT       NULL,
    ni_oke                    INT       NULL,
    pr_oke                    DEC(24,6) NULL,
    ni_nok                    INT       NULL,
    pr_nok                    DEC(24,6) NULL,
    ni_oos                    INT       NULL,
    pr_oos                    DEC(24,6) NULL,

);
GO