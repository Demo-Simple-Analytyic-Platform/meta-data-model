CREATE SCHEMA dta;
GO

/* Metadata Definitinions: */
EXEC sp_addextendedproperty  @name = N'metadata', @value = N'{
    "fn" : "Data Transformation Area (DTA)",
    "fd" : "All related object to \"Data Transformation Area (DTA)\" are located within this schema."
}', @level0type = N'SCHEMA',@level0name = N'dta';
GO