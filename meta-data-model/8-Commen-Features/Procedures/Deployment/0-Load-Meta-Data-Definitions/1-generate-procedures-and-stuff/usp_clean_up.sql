CREATE PROCEDURE deployment.usp_clean_up AS BEGIN

  DECLARE /* Local Variables */
    @tx_prc NVARCHAR(MAX),
    @tx_get NVARCHAR(MAX),
    @tx_tsa NVARCHAR(MAX),
    @tx_shm NVARCHAR(MAX);

  BEGIN

    DROP TABLE IF EXISTS ##tobe_dropped; SELECT 
      tx_prc = 'DROP PROCEDURE IF EXISTS ' + TABLE_SCHEMA + '.usp_' + TABLE_NAME,
      tx_get = 'DROP VIEW      IF EXISTS ' + TABLE_SCHEMA + '.get_' + TABLE_NAME,
      tx_tsa = 'DROP TABLE     IF EXISTS ' + TABLE_SCHEMA + '.tsa_' + TABLE_NAME,
      tx_shm = 'DROP SCHEMA              ' + TABLE_SCHEMA
    INTO ##tobe_dropped FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA IN ('tsa_srd' , 'tsa_ohg', 'tsa_dta', 'tsa_dqm');
	--SELECT * FROM ##tobe_dropped;
    
    WHILE ((SELECT COUNT(*) FROM ##tobe_dropped) > 0) BEGIN

      /* Fetch next nm_schema and nm_table */
      SELECT @tx_prc = tx_prc
           , @tx_get = tx_get
           , @tx_tsa = tx_tsa
           , @tx_shm = tx_shm
      FROM (SELECT TOP 1 * FROM ##tobe_dropped) AS rec;
	    DELETE FROM ##tobe_dropped WHERE tx_tsa = @tx_tsa;

      /* Create temp-table */
      PRINT(@tx_prc); EXEC sp_executesql @tx_prc;
      PRINT(@tx_get); EXEC sp_executesql @tx_get;
      PRINT(@tx_tsa); EXEC sp_executesql @tx_tsa;

      BEGIN TRY /* Drop Record from temp-table. */
	      PRINT(@tx_shm); EXEC sp_executesql @tx_shm;
      END TRY
	    BEGIN CATCH 
		    /* Print error message */
		    PRINT 'Error Number    : ' + CAST(ERROR_NUMBER() AS VARCHAR);
		    PRINT 'Error Severity  : ' + CAST(ERROR_SEVERITY() AS VARCHAR);
		    PRINT 'Error State     : ' + CAST(ERROR_STATE() AS VARCHAR);
		    PRINT 'Error Procedure : ' + ISNULL(ERROR_PROCEDURE(), '-');
		    PRINT 'Error Line      : ' + CAST(ERROR_LINE() AS VARCHAR);
		    PRINT 'Error Message   : ' + ERROR_MESSAGE();
	    END CATCH
	  
    END/* WHILE */

  END

END
GO