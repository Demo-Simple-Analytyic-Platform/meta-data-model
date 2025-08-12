CREATE TABLE ohg.related (

    /* Data Attributes */
    id_model           CHAR(32)     NULL,
    id_related         CHAR(32)     NULL,
    id_group           CHAR(32)     NULL,
    id_dataset         CHAR(32)     NULL,

    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT ohg_related_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Related (Groups)",
    "fd" : "A \"Dataset\" can be related to various \"Groups\" with this table this can be registered.",
    "bk" : ["id_model", "id_group", "id_dataset"]
}',
@level0type = N'SCHEMA', @level0name = N'ohg',
@level1type = N'TABLE',  @level1name = N'related';
GO

/* Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Related",
    "fd" : "Unique Identiefier for ohg.related"
}',
@level0type = N'SCHEMA', @level0name = N'ohg',
@level1type = N'TABLE',  @level1name = N'related',
@level2type = N'COLUMN', @level2name = N'id_related';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Group",
    "fd" : "Reference to ohg.groups"
}',
@level0type = N'SCHEMA', @level0name = N'ohg',
@level1type = N'TABLE',  @level1name = N'related',
@level2type = N'COLUMN', @level2name = N'id_group';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset",
    "fd" : "Reference to dta.datasets"
}',
@level0type = N'SCHEMA', @level0name = N'ohg',
@level1type = N'TABLE',  @level1name = N'related',
@level2type = N'COLUMN', @level2name = N'id_dataset';
GO