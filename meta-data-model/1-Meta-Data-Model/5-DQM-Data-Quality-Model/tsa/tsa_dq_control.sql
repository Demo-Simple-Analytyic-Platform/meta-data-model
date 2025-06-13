CREATE TABLE tsa_dqm.tsa_dq_control (

    /* Data dq_requirements */
    id_model                  CHAR(32)      NULL,
    id_dq_control             CHAR(32)      NULL,
    id_development_status     CHAR(32)      NULL,
    id_dq_requirement         CHAR(32)      NULL,
    id_dq_dimension           CHAR(32)      NULL,
    id_dataset                CHAR(32)      NULL,
    cd_dq_control             NVARCHAR(32)  NULL,
    fn_dq_control             NVARCHAR(128) NULL,
    fd_dq_control             NVARCHAR(999) NULL,
    tx_dq_control_query       NVARCHAR(MAX) NULL,
    dt_valid_from             DATE          NULL,
    dt_valid_till             DATE          NULL,

);
GO