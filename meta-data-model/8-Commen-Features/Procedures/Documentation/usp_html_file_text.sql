CREATE PROCEDURE mdm.usp_html_file_text
  
  @ip_id_model     CHAR(32),
  @ip_id_dataset   CHAR(32),
  @ip_tx_line      NVARCHAR(MAX)

AS DECLARE

  /* ----------------------------------------------------------------------- */
  /* This procedure will store a "line" of HTML-code for a documentation     */
  /* purposes. It will also ensure the is overarching "file"-record          */ 
  /* ----------------------------------------------------------------------- */
  
  @ni_line INT = ISNULL((SELECT COUNT(*) FROM mdm.html_file_text WHERE id_dataset = @ip_id_dataset),0);
  
BEGIN

  IF @ni_line = 0 BEGIN
     EXEC mdm.usp_html_file_name @ip_id_model, @ip_id_dataset;
  END;

  --PRINT(@ip_tx_line);

  INSERT INTO mdm.html_file_text (
    id_model, 
    id_dataset, 
    ni_line, 
    tx_line
  )
  VALUES (
    @ip_id_model,
    @ip_id_dataset, 
    @ni_line + 1, 
    ISNULL(@ip_tx_line, '<!-- empty string provided --!>')
  );

END
RETURN 0
