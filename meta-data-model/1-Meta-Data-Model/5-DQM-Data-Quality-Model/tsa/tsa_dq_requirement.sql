CREATE TABLE tsa_dqm.tsa_dq_requirement (

    /* Data dq_requirements */
    id_model                  CHAR(32)      NULL,
    id_dq_requirement         CHAR(32)      NULL,
    id_development_status     CHAR(32)      NULL,
    cd_dq_requirement         NVARCHAR(32)  NULL,
    fn_dq_requirement         NVARCHAR(128) NULL,
    fd_dq_requirement         NVARCHAR(999) NULL,
    dt_valid_from             DATE          NULL,
    dt_valid_till             DATE          NULL,

);
GO