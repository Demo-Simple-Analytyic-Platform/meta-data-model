CREATE TABLE mdm.validation_issues (
  id_model            CHAR(32)      NULL,
  id_dataset          CHAR(32)      NULL,
  nm_dataset          NVARCHAR(128) NULL,
  id_attribute        CHAR(32)      NULL,
  nm_attribute        NVARCHAR(128) NULL,
  nm_validation_issue NVARCHAR(128) NULL,
  ds_validation_issue NVARCHAR(999) NULL,
);