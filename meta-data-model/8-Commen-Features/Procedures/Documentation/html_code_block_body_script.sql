CREATE FUNCTION [mdm].[html_code_block_body_script] (

) RETURNS NVARCHAR(MAX) AS BEGIN 
  
  /* ----------------------------------------------------------------------- */
  /* This function will return "HTML"-code with "JavaScript"-code that will  */
  /* handle the behavior of the "code block"-button.                         */ 
  /* ----------------------------------------------------------------------- */
  
  DECLARE @return nvarchar(MAX) = '' 
  BEGIN
    SET @return += CHAR(10) + '      <script>' 
    SET @return += CHAR(10) + '        var coll = document.getElementsByClassName("collapsible");'
    SET @return += CHAR(10) + '        for (var i = 0; i < coll.length; i++) {'
    SET @return += CHAR(10) + '          coll[i].addEventListener("click", function() {' 
    SET @return += CHAR(10) + '            this.classList.toggle("active");' 
    SET @return += CHAR(10) + '            var content = this.nextElementSibling;' 
    SET @return += CHAR(10) + '            if (content.style.display === "block") { content.style.display ="none"; } ' 
    SET @return += CHAR(10) + '            else { content.style.display = "block"; }' 
    SET @return += CHAR(10) + '          });' 
    SET @return += CHAR(10) + '        }' 
    SET @return += CHAR(10) + '      </script>' 
  END
  RETURN @return;
END
GO
