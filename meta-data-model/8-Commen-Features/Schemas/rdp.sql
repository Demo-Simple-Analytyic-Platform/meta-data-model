CREATE SCHEMA rdp;
GO

/* Metadata Definitinions: */
EXEC sp_addextendedproperty  @name = N'metadata', @value = N'{
    "fn" : "Run Data Processing (RDP)",
    "fd" : "All related object to \"Data Processing\" are located within this schema."
}', @level0type = N'SCHEMA',@level0name = N'rdp';
GO
