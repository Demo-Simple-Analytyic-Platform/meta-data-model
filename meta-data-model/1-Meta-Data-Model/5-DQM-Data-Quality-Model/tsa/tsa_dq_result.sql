CREATE TABLE tsa_dqm.tsa_dq_result (

    /* Data dq_requirements */
    id_model             CHAR(32) NULL,
    id_dq_control        CHAR(32) NULL,
    id_dataset_1_bk      CHAR(32) NULL,
    id_dataset_2_bk      CHAR(32) NULL,
    id_dataset_3_bk      CHAR(32) NULL,
    id_dataset_4_bk      CHAR(32) NULL,
    id_dataset_5_bk      CHAR(32) NULL,
    id_dq_result_status  CHAR(32) NULL,

);
GO