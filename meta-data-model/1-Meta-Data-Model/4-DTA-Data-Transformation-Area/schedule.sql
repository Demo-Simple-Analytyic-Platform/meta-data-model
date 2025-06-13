CREATE TABLE dta.schedule (

    /* Data Attributes */
    id_model                  CHAR(32)      NULL,
    id_dataset                CHAR(32)      NULL,
    id_schedule               CHAR(32)      NULL,
    is_ingestion              BIT           NULL, 
    cd_frequency              NVARCHAR(32)  NULL,
    ni_interval               INT           NULL,
    dt_start                  DATE          NULL,
    dt_end                    DATE          NULL,
    
    /* Metadata Attributes */
    meta_dt_valid_from DATETIME NOT NULL,
    meta_dt_valid_till DATETIME NOT NULL,
    meta_is_active     BIT      NOT NULL,
    meta_ch_rh         CHAR(32) NOT NULL,
    meta_ch_bk         CHAR(32) NOT NULL,
    meta_ch_pk         CHAR(32) NOT NULL, 
    meta_dt_created    DATETIME NOT NULL DEFAULT GETDATE(), 

    /* Primarykey */
    CONSTRAINT dta_schedulet_pk PRIMARY KEY (meta_ch_pk),
    
);
GO

/*  Table Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Schedule",
    "fd" : "Meta Data of the \"Schedule\".",
    "bk" : ["id_model", "id_dataset"]
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name =N'schedule';
GO

/*  Column Metadata Definitinions: */
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Schedule",
    "fd" : "Unique Identiefier for dta.schedule"
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name =N'schedule',
@level2type = N'COLUMN', @level2name = N'id_schedule';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "ID Dataset",
    "fd" : "Reference to \"Dataset\"."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name =N'schedule',
@level2type = N'COLUMN', @level2name = N'id_dataset';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Frequency",
    "fd" : "The periode or \"Frequency\" on how the \"Interval\" is to be interpered."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name =N'schedule',
@level2type = N'COLUMN', @level2name = N'cd_frequency';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Interval",
    "fd" : "The \"Interval\" of the \"Frequency\" of the update \"Schedule\" should be triggered."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name =N'schedule',
@level2type = N'COLUMN', @level2name = N'ni_interval';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Schedule Start Date",
    "fd" : "The \"Startdate\" of the \"Schedule\" where \"Dataset\" should be updated."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'schedule',
@level2type = N'COLUMN', @level2name = N'dt_start';
GO
EXEC sp_addextendedproperty @name = N'metadata', @value = N'{
    "fn" : "Schedule End Date",
    "fd" : "The \"Enddate\" of the \"Schedule\" where \"Dataset\" should be updated."
}',
@level0type = N'SCHEMA', @level0name = N'dta',
@level1type = N'TABLE',  @level1name = N'schedule',
@level2type = N'COLUMN', @level2name = N'dt_end';
GO