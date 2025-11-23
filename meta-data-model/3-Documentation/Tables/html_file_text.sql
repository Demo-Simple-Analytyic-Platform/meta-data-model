CREATE TABLE documentation.html_file_text (

  id_model   CHAR(32)      NOT NULL,
  id_dataset CHAR(32)      NOT NULL,
  ni_line    INT           NOT NULL,
  tx_line    NVARCHAR(MAX) NOT NULL, 

  /* Primarykey */
  CONSTRAINT documentation_html_file_text_pk PRIMARY KEY ([id_model], [id_dataset], [ni_line]),

);
GO