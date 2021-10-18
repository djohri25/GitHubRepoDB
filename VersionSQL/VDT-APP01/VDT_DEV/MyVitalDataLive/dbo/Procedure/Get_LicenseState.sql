/****** Object:  Procedure [dbo].[Get_LicenseState]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:	
-- Create date: 
-- MODIFIED: 
-- Description:	Populates license state for the user (below)
-- Execution:  exec [Get_LicenseState] 'adbrightwell', 1,null
-- modified logic to display records based on county and state
-- =============================================

CREATE PROCEDURE [dbo].[Get_LicenseState] (@UserName varchar(100),@Status smallint, @IsActive bit = null)
AS 

 BEGIN 
 SET NOCOUNT ON;

--TEST SECTION
--declare 
--@UserName varchar(100) = 'adbrightwell',
--@Status smallint = 1,
--@IsActive bit = null


 IF @IsActive IS NULL 
 SET @IsActive= 1

IF @Status = 1
BEGIN
--SELECT QUERY 
 --   DROP TABLE #T
	--DROP TABLE #T1
	SELECT * INTO #T FROM dbo.NurseLicensure WHERE STATUS =1 AND username = @UserName
	
    SELECT * INTO #T1 FROM dbo.NurseLicensure WHERE STATUS >1 AND username = @UserName AND County <> 'null'

	SELECT A.[State] ,A.[Username],A.[status],A.County AS County
    FROM #T A
    WHERE
    NOT EXISTS (SELECT B.[State] ,B.[Username],B.[status],B.County AS County
    FROM #T1 B
    WHERE A.State = B.State 
    AND A.County = B.County
	)
	ORDER BY A.[State],A.County
	--select * from #T
	--select * from #T1
END


IF @Status > 1

BEGIN

	SELECT NL.[State] ,NL.[Username],NL.[status],NL.County AS County
	FROM [dbo].[NurseLicensure]  NL
	WHERE NL.UserName = @UserName
	AND NL.Status = @Status
	ORDER BY NL.[State],NL.County

END

END 