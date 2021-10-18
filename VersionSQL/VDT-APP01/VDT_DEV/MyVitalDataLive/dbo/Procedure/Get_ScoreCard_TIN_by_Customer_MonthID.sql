/****** Object:  Procedure [dbo].[Get_ScoreCard_TIN_by_Customer_MonthID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Example: EXEC dbo.Get_ScoreCard_TIN_by_Customer_MonthID @Cust_ID = 11, @MonthID = '201612'
-- Changes: 12/26/2017	MDeLuca	Removed unnecessary code
-- =============================================

CREATE PROCEDURE [dbo].[Get_ScoreCard_TIN_by_Customer_MonthID] 
	 @Cust_ID INT
	,@MonthID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MonthIDChar CHAR(6) = @MonthID

	SELECT DISTINCT m.ID, GroupName, ISNULL(LTRIM(RTRIM(SecondaryName)) + ' ' + '(' +GroupName+')',GroupName) AS SecondaryName, Active
	FROM dbo.MDGroup M 
	JOIN dbo.[Final_HEDIS_Member_FULL] g ON g.PCP_TIN = m.GroupName AND m.[CustID_Import] = g.CustID
	WHERE CustID_Import = @Cust_ID
	AND g.MonthID = @MonthIDChar
	AND Active = 1 
	AND groupname NOT IN ('dchpbeta1','dchpbeta2','dchpbeta3','XXXXXXXXX') 
	ORDER BY SecondaryName

END