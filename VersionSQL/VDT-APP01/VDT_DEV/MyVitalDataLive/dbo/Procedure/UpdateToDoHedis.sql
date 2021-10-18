/****** Object:  Procedure [dbo].[UpdateToDoHedis]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateToDoHedis]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	EXEC UpdateToDoHedisByTest  @LookupHedisTestID = 1 

	EXEC UpdateToDoHedisByTest  @LookupHedisTestID = 2 

	EXEC UpdateToDoHedisByTest  @LookupHedisTestID = 3 

	EXEC UpdateToDoHedisByTest  @LookupHedisTestID = 4 

	EXEC UpdateToDoHedisByTest  @LookupHedisTestID = 5 

	EXEC UpdateToDoHedisByTest  @LookupHedisTestID = 6 

	EXEC UpdateToDoHedisByTest  @LookupHedisTestID = 7 
END