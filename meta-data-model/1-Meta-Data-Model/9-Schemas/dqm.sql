CREATE SCHEMA dqm;
GO

/* Metadata Definitinions: */
EXEC sp_addextendedproperty  @name = N'metadata', @value = N'{
    "fn" : "Data Quality Model (DQM)",
    "fd" : "All related object to \"Data Quality Model (DQM)\" are located within this schema."
}', @level0type = N'SCHEMA',@level0name = N'dqm';
GO