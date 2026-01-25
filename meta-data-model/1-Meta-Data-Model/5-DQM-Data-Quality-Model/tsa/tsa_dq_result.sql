CREATE TABLE tsa_dqm.tsa_dq_result (

    /* Data dq_requirements */
    id_model             CHAR(32) NULL,
    id_dq_control        CHAR(32) NULL,
    id_dataset_1_bk      CHAR(32) NULL,
    id_dataset_2_bk      CHAR(32) NULL,
    id_dataset_3_bk      CHAR(32) NULL,
    id_dataset_4_bk      CHAR(32) NULL,
    id_dataset_5_bk      CHAR(32) NULL,
    dt_dq_result         DATETIME NULL,
    id_dq_result_status  CHAR(32) NULL,
    
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