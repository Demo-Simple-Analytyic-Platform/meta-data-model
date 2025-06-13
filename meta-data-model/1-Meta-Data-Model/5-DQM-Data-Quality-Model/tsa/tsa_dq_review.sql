CREATE TABLE tsa_dqm.tsa_dq_review (

    /* Data dq_requirements */
    id_model                  CHAR(32)      NULL,
    id_dq_review              CHAR(32)      NULL,
    id_dq_result              CHAR(32)      NULL,
    id_dq_review_status       CHAR(32)      NULL,
    dt_reviewed_at            DATE          NULL,
    nm_reviewed_by            NVARCHAR(128) NULL,
    tx_reviewed_report        NVARCHAR(MAX) NULL,
    dt_validated_at           DATE          NULL,
    nm_validated_by           NVARCHAR(128) NULL,
    tx_validated_report       NVARCHAR(MAX) NULL,
    
);
GO