CREATE FUNCTION [mdm].[json_count] (
  
  /* Input Parameters */
  @ip_tx_json_array NVARCHAR(MAX)

) RETURNS INT AS BEGIN DECLARE 
  
  /* ----------------------------------------------------------------------- */
  /* This function will return the number of JSON-objects in a JSON-Array    */
  /* "@ip_tx_json_array".                                                    */ 
  /* ----------------------------------------------------------------------- */
  
  @retrun INT;

  BEGIN

    SET @retrun = LEN(@ip_tx_json_array) - LEN(REPLACE(@ip_tx_json_array, '{', ''));
  
  END

  /* Return */
  RETURN @retrun;

END
GO