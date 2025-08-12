CREATE TABLE mdm.html_file_name (

  id_model     CHAR(32)      NOT NULL,
  id_dataset   CHAR(32)      NOT NULL,
  nm_file_name NVARCHAR(128) NOT NULL,
  ds_file_path NVARCHAR(128) NOT NULL, 

  /* Primarykey */
  CONSTRAINT mdm_html_file_name_pk PRIMARY KEY ([id_model], [id_dataset]),

);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Meta Attributes",
    "fd" : "Placeholder for \"Functional\"- names and -descriptions of the \"Mata Attributes\"."
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'html_file_name';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset",
    "fd" : "Reference to \"Dataset\" for which this documentation file is for."
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'html_file_name',
@level2type = N'COLUMN', @level2name = N'id_dataset';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Filename",
    "fd" : "This is the \"Name\" of the file, it should follow \"<id_datasaet>.html\"-naming convention."
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'html_file_name',
@level2type = N'COLUMN', @level2name = N'nm_file_name';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Filepath",
    "fd" : "This is relative path where the file should be stored on a (static) Webserver."
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'html_file_name',
@level2type = N'COLUMN', @level2name = N'ds_file_path';
GO
