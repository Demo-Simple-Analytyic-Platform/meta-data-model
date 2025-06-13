CREATE SCHEMA mdm;
GO

/* Functional Name: */
EXEC sp_addextendedproperty  @name = N'fn', @value = N'Meta Data Model (MDM)',
    @level0type = N'SCHEMA',
    @level0name = N'mdm';
GO
/* Functional Description: */
EXEC sp_addextendedproperty  @name = N'fd', @value = N'All related object to "Meta Data Model (MDM)" are located within this schema, in this schema the information of OHG, SRD, DTA, DQM, DTP and DQP comes together.',
    @level0type = N'SCHEMA',
    @level0name = N'mdm';
GO


