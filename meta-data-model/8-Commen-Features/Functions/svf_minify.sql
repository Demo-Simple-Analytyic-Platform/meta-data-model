CREATE FUNCTION gnc_commen.svf_minify ( 

    /* Input Parameter(s) */
    @ip_tx_text_with_comments NVARCHAR(MAX)
    
) RETURNS NVARCHAR(MAX) /* Text without Comments */ AS BEGIN
  
  /* ----------------------------------------------------------------------- */
  /* This function will remove all non essential elements from a "query".    */ 
  /* ----------------------------------------------------------------------- */
  
 DECLARE @tx_minified NVARCHAR(MAX) = TRIM(gnc_commen.svf_strip_comments(@ip_tx_text_with_comments));
 
 DECLARE @cp INT  = 1
 DECLARE @np INT  = 0
 DECLARE @lp INT  = LEN(@tx_minified)
 DECLARE @cc CHAR(1)
 DECLARE @nc CHAR(1)
 DECLARE @pd BIT
 DECLARE @i INT = 0       -- Iteration Counter
 DECLARE @m INT = 1000000 -- Max Iterations -> # 100.000 Characters is "more than enough" for a SQL Statement.
 DECLARE @e NVARCHAR(999) = ''

 /* Replace "newlines" with "single"-space. */
 SET @tx_minified = REPLACE(@tx_minified, CHAR(10), ' ');
 SET @tx_minified = REPLACE(@tx_minified, CHAR(13), ' ');
 
 WHILE (@cp < @lp AND @i < @m) BEGIN SET @i += 1;
 
   IF (1=1 /* Set "Current" and "Next" positions. */) BEGIN
       SET @pd = 0;
       SET @np = @cp + 1;
       SET @cc = SUBSTRING(@tx_minified, @cp, 1);
       SET @nc = SUBSTRING(@tx_minified, @np, 1);
   END;
 
   IF (@pd = 0 AND @cc  = ' ' AND @nc = ' ')  BEGIN SET @pd = 1; SET @tx_minified = SUBSTRING(@tx_minified, 1, @cp) + SUBSTRING(@tx_minified, @np+1, @lp); END;
   IF (@pd = 0 AND @cc  = ' ' AND @nc = '[')  BEGIN SET @pd = 1; SET @cp = CHARINDEX(']',  @tx_minified, @cp+1) + 1; END;
   IF (@pd = 0 AND @cc  = ' ' AND @nc = '''') BEGIN SET @pd = 1; SET @cp = CHARINDEX('''', @tx_minified, @cp+1) + 1; END;
   IF (@pd = 0 AND @cc != ' ' AND @nc = '[')  BEGIN SET @pd = 1; SET @cp = CHARINDEX(']',  @tx_minified, @cp+1) + 1; END;
   IF (@pd = 0 AND @cc != ' ' AND @nc = '''') BEGIN SET @pd = 1; SET @cp = CHARINDEX('''', @tx_minified, @cp+1) + 1; END;
   IF (@pd = 0)                               BEGIN SET @pd = 1; SET @cp += 1; END;

   /* Prevent "infinite" loop. */
    
 
   /* Re-Calculate "Length" SQL Statement. */
   SET @lp = LEN(@tx_minified);
 
   /* Exit if there are no more "space". */
   IF (@cp = 0) BEGIN SET @cp = @lp; END;
 
 END;

 IF (@i = @m) BEGIN
   SET @e     = '--- Warning --------------------------------------------------------------'
   + CHAR(10) + '  Function gnc_commen.svf_minify reached maximum iterations (' + CAST(@m AS NVARCHAR(10)) + ').'
   + CHAR(10) + '  Please check input for irregularities.'
   + CHAR(10) + '---------------------------------------------------------------------------'
   SET @tx_minified = @e;
 END
 
 /* All Done, return output */
 RETURN @tx_minified

END
GO
