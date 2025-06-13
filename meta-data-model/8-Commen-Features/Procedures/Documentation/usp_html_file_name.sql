CREATE PROCEDURE mdm.usp_html_file_name 

  @ip_id_model   CHAR(32),    -- Model identifier 
  @ip_id_dataset NVARCHAR(32) -- Dataset identifier Normally always CHAR(32) but for the "main" it should be nvarchar(32)

AS BEGIN

  /* ----------------------------------------------------------------------- */
  /* This procedure will store a "file"-record for HTML-document.            */ 
  /* ----------------------------------------------------------------------- */
  
  DELETE FROM mdm.html_file_name 
  WHERE id_dataset = @ip_id_dataset
  AND   id_model   = @ip_id_model;

  INSERT INTO mdm.html_file_name (
    id_model,
    id_dataset,
    nm_file_name,
    ds_file_path
  ) VALUES (
    @ip_id_model, 
    @ip_id_dataset, 
    IIF(@ip_id_dataset = '-1', 'main', @ip_id_dataset) + '.html', 
    IIF(@ip_id_dataset = '-1', '', 'datasets\')
  );

END