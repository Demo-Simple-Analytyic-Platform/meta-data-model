CREATE TABLE mdm.meta_attributes (

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Meta Attributes",
    "fd" : "Placeholder for \"Functional\"- names and -descriptions of the \"Mata Attributes\"."
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'meta_attributes';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Meta Valid From",
    "fd" : "Meta Attribute to register of the \"from\"-moment from which the \"record\" is valid."
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'meta_attributes',
@level2type = N'COLUMN', @level2name = N'meta_dt_valid_from';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Meta Valid Till",
    "fd" : "Meta Attribute to register of the \"till\"-moment from which the \"record\" is NO longer valid."
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'meta_attributes',
@level2type = N'COLUMN', @level2name = N'meta_dt_valid_till';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Meta Is Active",
    "fd" : "Meta Attribute to register if the \"record\" is \"Active\"."
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'meta_attributes',
@level2type = N'COLUMN', @level2name = N'meta_is_active';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Meta Row Hash",
    "fd" : "Meta Attribute to register of the a 32-character string representation of a MD5-hash of all the \"Data\"-attributes of a \"Dataset\"-record. (non-data-attributes are \"meta_dt_valid_from, meta_dt_valid_till, meta_is_active, meta_ch_rh, meta_ch_bk, meta_ch_pk\")."
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'meta_attributes',
@level2type = N'COLUMN', @level2name = N'meta_ch_rh';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Meta Businesskey(s) Hash",
    "fd" : "Meta Attribute to register of the a 32-character string representation of a MD5-hash of all \"Businesskey(s)\". "
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'meta_attributes',
@level2type = N'COLUMN', @level2name = N'meta_ch_bk';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Meta Primarykey(s) Hash",
    "fd" : "Meta Attribute to register of the a 32-character string representation of a MD5-hash of all \"Businesskey(s)\" plus the \"meta_dt_from\"-value. The value registered in this meta attribute must always be unique over the whole datasets."
}',
@level0type = N'SCHEMA', @level0name = N'mdm',
@level1type = N'TABLE',  @level1name = N'meta_attributes',
@level2type = N'COLUMN', @level2name = N'meta_ch_pk';
GO