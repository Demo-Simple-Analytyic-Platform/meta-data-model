CREATE FUNCTION gnc_commen.svf_strip_comments ( 

  /* Input Parameter(s) */
  @ip_tx_text_with_comments NVARCHAR(MAX)
  
) RETURNS NVARCHAR(MAX) /* Text without Comments */ AS BEGIN
  
  /* ----------------------------------------------------------------------- */
  /* This function will remove all "comments" from a "query".                */ 
  /* ----------------------------------------------------------------------- */
  
  DECLARE @Sqlcode VARCHAR(MAX) = @ip_tx_text_with_comments

  Declare @tx_text_without_comments NVARCHAR(MAX)=''

  Declare @i               INT  = 0
  Declare @Char1           CHAR(1)
  Declare @Char2           CHAR(1)
  Declare @TrailingComment CHAR(1) = 'N'
  Declare @Whackcounter    INT = 0
  Declare @max             INT = DATALENGTH(@ip_tx_text_with_comments)
  
  /* Loop though every single Character in the Text */
  WHILE @i < @max BEGIN

    /* Extract the Next Character */
    Select @Char1 = Substring(@Sqlcode,@i,1)

    /* Determine if Character is "Comment" related */
    IF @Char1 NOT IN ('-', '/','''','*')  BEGIN

      /* Check if character is "New"-line character */
      IF (@Char1 = CHAR(13) or @Char1 = CHAR(10)) BEGIN SET @TrailingComment = 'N'; END

      /* Check if NOT Space or Tab */
      ELSE IF (NOT (@Char1 = CHAR(32) or @Char1 = CHAR(9)) and @TrailingComment = 'N') BEGIN SET @TrailingComment = 'Y'; END

      /* Add Character to "Text" withoiut "Comments" */
      IF (@Whackcounter = 0) BEGIN SET @tx_text_without_comments += @Char1; END

      /* Add 1 to "Index" for next Character to be examined */
      SET @i += 1;

    END
    
    /* If "Comment"-related Character */
    ELSE BEGIN

      /* Set Char2 with previous Character */
      SET @Char2 = @Char1

      /* Fetch Next Character */
      SET @Char1 = Substring(@Sqlcode,@i+1,1)

      /* Check if comment characters are found */
      If (@Char1 = '-' and @Char2 = '-' and @Whackcounter = 0) BEGIN
        
        /* Loop thought the characters until "Newline"-charater is found */
        While (@i < @Max AND SUBSTRING(@Sqlcode,@i,1) NOT IN (CHAR(13), CHAR(10))) BEGIN SET @i += 1; END

        /* Check if what type of "newline"-character is found */
        IF (SUBSTRING(@Sqlcode,@i,1) = char(13) AND @TrailingComment = 'N') BEGIN SET @i += 1; END
        IF (SUBSTRING(@Sqlcode,@i,1) = char(10) and @TrailingComment = 'N') BEGIN SET @i += 1; END

      END

      /* Check if in-line comment "end" is found */
      ELSE IF (@Char1 = '*' and @Char2 = '/') BEGIN 

        SET @Whackcounter += 1

        /* Add 1 to "Index" for next Character to be examined, but skip one */
        SET @i += 2

      END
      
      /* Check if in-line comment "start" is found */
      ELSE IF (@Char1 = '/' and @Char2 = '*') BEGIN
        
        SET @Whackcounter -= 1

        /* Add 1 to "Index" for next Character to be examined, but skip one */
        SET @i += 2

      END
          
      /* Check if single "qout"-character is found */    
      ELSE IF (@char2 = '''' and @Whackcounter = 0) BEGIN

        /* Add found character to output */
        SET @tx_text_without_comments += @char2

        /* Loop thought "Text" until "new" single "quot"-character is found */
        WHILE (SUBSTRING(@Sqlcode,@i,1) <> '''') BEGIN
          
          /* Add found character to output */
          SET @tx_text_without_comments += Substring(@Sqlcode,@i,1)

          /* Add 1 to "Index" for next Character to be examined */
          SET @i +=1

        END

        /* Add 1 to "Index" for next Character to be examined */
        SET @i +=1

        /* Get next character */
        SET @Char1 = Substring(@Sqlcode,@i,1)

      END
      
      ELSE BEGIN
        
        /* Add found character to output */
        if (@Whackcounter = 0) BEGIN SET @tx_text_without_comments += @Char2; END
        
        /* Add 1 to "Index" for next Character to be examined */
        SET @i +=1

      END
  
    END
  
  END

  /* All Done, return output */
  RETURN @tx_text_without_comments

END
GO