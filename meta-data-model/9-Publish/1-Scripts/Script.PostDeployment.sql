INSERT INTO [mdm].[meta_attributes] ([meta_dt_valid_from], [meta_dt_valid_till], [meta_is_active], [meta_ch_rh], [meta_ch_bk], [meta_ch_pk], [meta_dt_created])
SELECT [meta_dt_valid_from], [meta_dt_valid_till], [meta_is_active], [meta_ch_rh], [meta_ch_bk], [meta_ch_pk], [meta_dt_created] FROM (
    SELECT GETDATE() AS [meta_dt_valid_from]
           , GETDATE() AS [meta_dt_valid_till]
           , 1         AS [meta_is_active]
           , 'N/A'     AS [meta_ch_rh]
           , 'N/A'     AS [meta_ch_bk]
           , 'N/A'     AS [meta_ch_pk]
           , GETDATE() AS [meta_dt_created]
) AS val WHERE 1 > (SELECT COUNT(*) FROM mdm.meta_attributes);
GO
