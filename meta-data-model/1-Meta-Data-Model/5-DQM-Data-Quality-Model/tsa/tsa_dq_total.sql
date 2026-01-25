CREATE TABLE tsa_dqm.tsa_dq_totals (

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

    /* Metadata dq_requirements */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

);
GO