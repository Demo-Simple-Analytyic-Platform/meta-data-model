CREATE PROCEDURE mdm.usp_html_print_to_console
  
  @ip_id_model     CHAR(32),
  @ip_id_dataset   CHAR(32),
  @ip_is_debugging BIT = 0

AS DECLARE

  /* ----------------------------------------------------------------------- */
  /* This procedure will print the whole HTML-document to the window consol  */ 
  /* if @ip_is_debugging is set to 1. This is usefull when extending the     */
  /* documentation generation logic.                                         */
  /* ----------------------------------------------------------------------- */
  
  @tx_lines NVARCHAR(MAX)= ''; 

BEGIN

    IF (@ip_is_debugging = 1 /* Output HTML */) BEGIN 
        SELECT @tx_lines += html.tx_line + CHAR(10) 
        FROM (
            SELECT tx_line, ni_line
            FROM mdm.html_file_text
            WHERE id_model   = @ip_id_model
            AND   id_dataset = @ip_id_dataset
        ) AS html
        ORDER BY ni_line ASC;
        EXEC gnc_commen.to_concol_window @tx_lines;
    END
END
RETURN 0
