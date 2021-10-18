/****** Object:  Procedure [dbo].[DashboardMeasuresByNPI]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Example:	EXEC dbo.DashboardMeasuresByNPI @CustID = 11, @NPI = '1053311829', @Measure = 'AWC'
-- =============================================
CREATE PROCEDURE [dbo].[DashboardMeasuresByNPI]
	 @CustID INT
	,@NPI VARCHAR(15)
	,@Measure VARCHAR(15)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @MaxMonthID CHAR(6)

	SELECT @MaxMonthID = MAX(MonthID) FROM dbo.Final_HEDIS_Member_FULL WHERE CustID = @CustID

	SELECT 
--	 F.MVDID
	 F.MemberID
	,F.MemberFirstName
	,F.MemberLastName
	,F.IsTestDue
	,F.HasAsthma
	,F.HasDiabetes
	,CAST(SUBSTRING(
		( 
			SELECT DISTINCT ','+CAST(Abbreviation AS VARCHAR(10)) 
			FROM dbo.Final_HEDIS_Member_FULL FX
			JOIN dbo.HedisSubmeasures SX ON FX.TestID = SX.ID
			WHERE FX.CustID = @CustID
			AND FX.PCP_NPI = @NPI
			AND SX.Abbreviation <> @Measure
			AND FX.MonthID = @MaxMonthID
			AND FX.MVDID = F.MVDID
			FOR XML PATH('')),2,200000
		) AS VARCHAR(200)) AS OtherMeasures
	FROM dbo.Final_HEDIS_Member_FULL F
	JOIN dbo.HedisSubmeasures S ON F.TestID = S.ID
	--JOIN dbo.Link_MemberId_MVD_Ins I ON F.MVDID = I.MVDId AND I.Cust_ID = @CustID
	--JOIN dbo.MainPersonalDetails D ON I.MVDId = D.ICENUMBER
	WHERE F.CustID = @CustID
	AND F.PCP_NPI = @NPI
	AND S.Abbreviation = @Measure
	AND F.MonthID = @MaxMonthID
	END