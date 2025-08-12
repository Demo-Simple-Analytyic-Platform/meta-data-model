CREATE SCHEMA deployment;
GO

/* Metadata Definitinions: */
EXEC sp_addextendedproperty  @name = N'metadata', @value = N'{
    "fn" : "Deployment",
    "fd" : "This Schema is used to add Procedures en Function that execute deployment things."
}', @level0type = N'SCHEMA',@level0name = N'deployment';
GO