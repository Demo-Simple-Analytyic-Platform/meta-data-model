CREATE TABLE ohg.hierarchy (

    /* Data Attributes */
    id_model            CHAR(32)    NULL,
    id_hierarchy        CHAR(32)    NULL,
    id_group            CHAR(32)    NULL,
    id_hierarchy_parent CHAR(32)    NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT ohg_hierarchy_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "hierarchy (of Groups)",
    "fd" : "A \"Group\" can be organized into \"Hierarchy\" or be part of miltiple "hierarchy" that related to other part of the \"Business\". Think of how \"operations\" and \"sales\" would organize the datasets and relate datasets to one another, this would likely be simular but not the same. However they should uses the same datasets and NOT create separated \"truths\"!",
    "bk" : ["id_model", "id_group_parent", "id_group_child"]
}',
@level0type = N'SCHEMA', @level0name = N'ohg',
@level1type = N'TABLE',  @level1name = N'hierarchy';
GO

/* Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Hierarchy",
    "fd" : "Unique Identiefier for ohg.hierarchy"
}',
@level0type = N'SCHEMA', @level0name = N'ohg',
@level1type = N'TABLE',  @level1name = N'hierarchy',
@level2type = N'COLUMN', @level2name = N'id_hierarchy';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Group",
    "fd" : "Reference to ohg.groups"
}',
@level0type = N'SCHEMA', @level0name = N'ohg',
@level1type = N'TABLE',  @level1name = N'hierarchy',
@level2type = N'COLUMN', @level2name = N'id_group';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Hierarchy (parent)",
    "fd" : "Reference to ohg.hierarchy"
}',
@level0type = N'SCHEMA', @level0name = N'ohg',
@level1type = N'TABLE',  @level1name = N'hierarchy',
@level2type = N'COLUMN', @level2name = N'id_hierarchy_parent';
GO