CREATE SCHEMA gnc_commen;
GO

/* Metadata Definitinions: */
EXEC sp_addextendedproperty  @name = N'metadata', @value = N'{
    "fn" : "Generic Commen Functions",
    "fd" : "This Schema is used to add Procedures en Function that execute generic commen things."
}', @level0type = N'SCHEMA',@level0name = N'gnc_commen';
GO