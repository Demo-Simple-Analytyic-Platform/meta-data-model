CREATE FUNCTION [mdm].[html_code_block_body_part] (

  @ip_tx_sql_code_block NVARCHAR(MAX)

) RETURNS NVARCHAR(MAX) AS BEGIN 
  
  /* ----------------------------------------------------------------------- */
  /* This function will return "HTML"-code with a "code block" to be insert  */
  /* into the text of a html page being constructed.                         */ 
  /* ----------------------------------------------------------------------- */
  
  DECLARE @return nvarchar(MAX) = '' 
  BEGIN
    SET @return += '<button class="collapsible">Show SQL Code</button><div class="content"><pre><code>'
    SET @return += REPLACE(@ip_tx_sql_code_block, '<newline>', '<br>')
    SET @return += '</code></pre></div>';
  END
  RETURN @return;
END
GO

