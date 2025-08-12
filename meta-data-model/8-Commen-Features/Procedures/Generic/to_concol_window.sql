CREATE PROCEDURE gnc_commen.to_concol_window

	/* input Prarmeters */
	@ip_tx_to_print  NVARCHAR(MAX)

AS DECLARE /* Local Variables */
  
  /* ----------------------------------------------------------------------- */
  /* This procedure will print any text up to 20.000 character to the window */
  /* consol. It will print it line by line if "newline"-character CHAR(10)   */
  /* are used. If not set of max 4000 character are printed. With a limit of */
  /* 20.000 characters.                                                      */ 
  /* ----------------------------------------------------------------------- */
  
  @ni_printed INT = 0,
  @ni_nxt_nwl INT = 0;

BEGIN

    /* Determine the first CHAR(10) "New Line"-character */
    SET @ni_nxt_nwl = CHARINDEX(CHAR(10), @ip_tx_to_print, 1);

    IF (@ni_nxt_nwl > 0) BEGIN 
    
        WHILE @ni_printed < @ni_nxt_nwl BEGIN

            -- Print till the @ni_nxt_nwl
            PRINT(SUBSTRING(@ip_tx_to_print, @ni_printed, @ni_nxt_nwl-@ni_printed))

            -- Find next CHAR(10)
            SET @ni_printed = @ni_nxt_nwl + 1; 
            SET @ni_nxt_nwl = CHARINDEX(CHAR(10), @ip_tx_to_print, @ni_printed+1);

        END; 

        -- Print the last part
        PRINT(SUBSTRING(@ip_tx_to_print, @ni_printed, LEN(@ip_tx_to_print)-@ni_printed+1))
    
    END

    ELSE BEGIN
        
        PRINT(SUBSTRING(@ip_tx_to_print, 1, 4000));

        IF (LEN(@ip_tx_to_print) >  4000) BEGIN PRINT(SUBSTRING(@ip_tx_to_print,  4001,  8000)); END
        IF (LEN(@ip_tx_to_print) >  8000) BEGIN PRINT(SUBSTRING(@ip_tx_to_print,  8001, 12000)); END
        IF (LEN(@ip_tx_to_print) > 12000) BEGIN PRINT(SUBSTRING(@ip_tx_to_print, 12001, 16000)); END
        IF (LEN(@ip_tx_to_print) > 16000) BEGIN PRINT(SUBSTRING(@ip_tx_to_print, 16001, 20000)); END

    END

END