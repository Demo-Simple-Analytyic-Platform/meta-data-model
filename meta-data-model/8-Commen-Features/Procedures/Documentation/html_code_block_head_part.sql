CREATE FUNCTION [mdm].[html_code_block_head_part] (

) RETURNS NVARCHAR(MAX) AS BEGIN
  
  /* ----------------------------------------------------------------------- */
  /* This function will return "HTML"-code with "Style"-code that will set   */
  /* the apperance of the (un)callapsed "Code blokc" on the "HTML"-page.     */ 
  /* ----------------------------------------------------------------------- */
  
  DECLARE @return nvarchar(MAX) = '' 
  BEGIN
    SET @return += CHAR(10) + '      <style>'
    SET @return += CHAR(10) + '        .collapsible {'
    SET @return += CHAR(10) + '            background-color: #f1f1f1;'
    SET @return += CHAR(10) + '            color: #444;'
    SET @return += CHAR(10) + '            cursor: pointer;'
    SET @return += CHAR(10) + '            padding: 10px;'
    SET @return += CHAR(10) + '            width: 100%;'
    SET @return += CHAR(10) + '            border: none;'
    SET @return += CHAR(10) + '            text-align: left;'
    SET @return += CHAR(10) + '            outline: none;'
    SET @return += CHAR(10) + '            font-size: 15px;'
    SET @return += CHAR(10) + '        }'
    SET @return += CHAR(10) + '        .active, .collapsible:hover {'
    SET @return += CHAR(10) + '            background-color: #ccc;'
    SET @return += CHAR(10) + '        }'
    SET @return += CHAR(10) + '        .content {'
    SET @return += CHAR(10) + '            padding: 0 18px;'
    SET @return += CHAR(10) + '            display: none;'
    SET @return += CHAR(10) + '            overflow: hidden;'
    SET @return += CHAR(10) + '            background-color: #f9f9f9;'
    SET @return += CHAR(10) + '        }'
    SET @return += CHAR(10) + '        pre {'
    SET @return += CHAR(10) + '            background-color: #eee;'
    SET @return += CHAR(10) + '            padding: 10px;'
    SET @return += CHAR(10) + '            border-radius: 5px;'
    SET @return += CHAR(10) + '        }'
    SET @return += CHAR(10) + '      </style>'
  END
  RETURN @return;
END
GO