CREATE TABLE tsa_srd.tsa_dq_risk_level (

    /* Data Attributes */
    id_model         CHAR(32)      NULL,
    id_dq_risk_level CHAR(32)      NULL,
    cd_dq_risk_level NVARCHAR(32)  NULL,
    fn_dq_risk_level NVARCHAR(128) NULL,
    fd_dq_risk_level NVARCHAR(999) NULL,
    cd_dq_status     NVARCHAR(32)  NULL,
    fn_dq_status     NVARCHAR(128) NULL,
    fd_dq_status     NVARCHAR(999) NULL,

);
GO