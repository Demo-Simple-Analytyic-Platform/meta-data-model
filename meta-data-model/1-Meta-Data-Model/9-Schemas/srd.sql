CREATE SCHEMA srd;
GO

/* Metadata Definitinions: */
EXEC sp_addextendedproperty  @name = N'metadata', @value = N'{
    "fn" : "Static Reference Data (SRD)",
    "fd" : "All related object to \"Static Reference Data (SRD)\" are located within this schema."
}', @level0type = N'SCHEMA',@level0name = N'srd';
GO