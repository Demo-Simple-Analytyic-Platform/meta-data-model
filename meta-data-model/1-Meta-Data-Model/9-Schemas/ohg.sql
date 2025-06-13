CREATE SCHEMA ohg;
GO

/* Metadata Definitinions: */
EXEC sp_addextendedproperty  @name = N'metadata', @value = N'{
    "fn" : "Organisation Hierarchy Group (OHG)",
    "fd" : "All related object to \"Organisation Hierarchy Group (OHG)\" are located within this schema."
}', @level0type = N'SCHEMA',@level0name = N'ohg';
GO