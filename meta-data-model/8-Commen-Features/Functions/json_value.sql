CREATE FUNCTION [mdm].[json_value] (
  
  /* Input Parameters */
  @ip_ni_json_array     INT,
  @ip_tx_json_array     NVARCHAR(MAX),
  @ip_nm_json_attribute NVARCHAR(128)

) RETURNS NVARCHAR(MAX) AS BEGIN DECLARE 
  
  /* ----------------------------------------------------------------------- */
  /* This function will return the value of JSON-attribute from the input    */
  /* parameters @ip_tx_json_array and @ip_nm_json_attribute. With the        */
  /* parameter @ip_ni_json_array the position in the array can be chosen.    */ 
  /* ----------------------------------------------------------------------- */
  
  @retrun NVARCHAR(MAX);

  BEGIN

    SELECT @retrun = CONVERT(NVARCHAR(MAX), JSON_VALUE([json].[value], '$.'+@ip_nm_json_attribute) )
    FROM OPENJSON(@ip_tx_json_array) AS [json]
    WHERE [json].[key] = @ip_ni_json_array 
  

  END

  /* Return */
  RETURN @retrun;

END