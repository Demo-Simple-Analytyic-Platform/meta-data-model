CREATE TABLE mdm.html_file_text (

  id_model   CHAR(32)      NOT NULL,
  id_dataset CHAR(32)      NOT NULL,
  ni_line    INT           NOT NULL,
  tx_line    NVARCHAR(MAX) NOT NULL, 

  /* Primarykey */
  CONSTRAINT mdm_html_file_text_pk PRIMARY KEY ([id_model], [id_dataset], [ni_line]),

);
GO
/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Meta Attributes",
    "fd" : "Placeholder for \"Functional\"- names and -descriptions of the \"Mata Attributes\"."
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'html_file_text';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset",
    "fd" : "Reference to \"Dataset\" for which this documentation file is for."
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'html_file_text',
@level2type = N'COLUMN', @level2name = N'id_dataset';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "# Line",
    "fd" : "This line \"Number\" to ensure the correct order can be maintained."
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'html_file_text',
@level2type = N'COLUMN', @level2name = N'ni_line';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Line text",
    "fd" : "This \"Text\" of the line, for documentation it should be HTML or supported by HTML."
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'html_file_text',
@level2type = N'COLUMN', @level2name = N'tx_line';
GO

