CREATE TABLE documentation.html_file_name (

  id_model     CHAR(32)      NOT NULL,
  id_dataset   CHAR(32)      NOT NULL,
  nm_file_name NVARCHAR(128) NOT NULL,
  ds_file_path NVARCHAR(128) NOT NULL, 

  /* Primarykey */
  CONSTRAINT documentation_html_file_name_pk PRIMARY KEY ([id_model], [id_dataset]),

);
GO