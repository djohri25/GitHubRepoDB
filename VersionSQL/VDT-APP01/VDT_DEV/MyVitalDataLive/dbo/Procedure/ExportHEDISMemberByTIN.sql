/****** Object:  Procedure [dbo].[ExportHEDISMemberByTIN]    Committed by VersionSQL https://www.versionsql.com ******/

-- Exec [ExportHEDISMemberByTIN] @CustID = 10, @TIN ='COPC000012', @MonthID = '201809', @LOB = 'ALL', @NPI = '1538101027'
CREATE PROCEDURE [dbo].[ExportHEDISMemberByTIN]
	@CustID int,
	@TIN varchar(50),
	@NPI varchar(50) = 'ALL',
	@MonthID char(6) = NULL,
	@LOB varchar(50) = 'ALL'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MonthIDCheck INT

	SELECT TOP 1 @MonthIDCheck = MonthID
	FROM [dbo].[Final_HEDIS_Member]
	WHERE CustID = @CustID
	ORDER BY MonthID DESC

	IF (@MonthID IS NULL OR @MonthIDCheck = @MonthID)
	BEGIN
		SET @MonthID = @MonthIDCheck
		SELECT DISTINCT
			@MonthID as MeasurePeriod
			,@TIN as TIN
			,c.Abbreviation as MeasureAbbreviation
			,c.[Name] as MeasureName
			,b.Abbreviation as SubMeasureAbbreviation
			,b.[Name] as SubMeasureName
			,[PCP_NPI] as NPI
			,CASE
				WHEN d.[Provider Organization Name (Legal Business Name)] != '' THEN d.[Provider Organization Name (Legal Business Name)]
				ELSE dbo.fullName(d.[Provider Last Name (Legal Name)], d.[Provider First Name], '')
			END AS ProviderName
			,a.[MemberID]
			,a.[MemberFirstName]
			,a.[MemberLastName]
			,a.[DOB]
			,a.[IsTestDue] as Compliant
			,a.[LOB]
			,a.[SDA] as ServiceArea
			,CASE
				WHEN ISNULL(e.HomePhone, '') = '' THEN e.CellPhone
				ELSE e.HomePhone
			END AS [Phone Number]
		FROM [dbo].[Final_HEDIS_Member] a
		JOIN [dbo].[HedisSubmeasures] b ON a.[TestID] = b.ID
		JOIN [dbo].[HedisMeasures] c ON b.MeasureID = c.ID
		JOIN [dbo].[HedisScorecard] f ON b.ID = f.SubmeasureID AND f.CustID = @CustID
		LEFT JOIN [dbo].[HedisScorecard_TIN] g ON f.ID = g.ScoreCardID AND (ISNULL(g.TIN, 0) = @TIN)
		LEFT JOIN [dbo].[LookupNPI] d ON a.PCP_NPI = d.NPI
		LEFT JOIN dbo.MainPersonalDetails e ON a.MVDID = e.ICENUMBER
		WHERE a.CustID = @CustID
			AND a.[PCP_TIN] = @TIN
			AND a.MonthID = @MonthID
			AND (ISNULL(f.DRLink_Active, 0) = 1 OR ISNULL(g.DRLink_Active, 0) = 1)
			AND a.LOB = (CASE
							WHEN (@LOB = 'ALL') THEN a.LOB
							ELSE @LOB
						END)
			AND a.PCP_NPI = (CASE
							WHEN (@NPI = 'ALL') THEN a.PCP_NPI
							ELSE @NPI
						END)
		ORDER BY MeasureAbbreviation, SubMeasureAbbreviation, ProviderName, [MemberLastName], [MemberFirstName]
	END
	ELSE
	BEGIN
		SELECT DISTINCT
			@MonthID as MeasurePeriod
			,@TIN as TIN
			,c.Abbreviation as MeasureAbbreviation
			,c.[Name] as MeasureName
			,b.Abbreviation as SubMeasureAbbreviation
			,b.[Name] as SubMeasureName
			,[PCP_NPI] as NPI
			,CASE
				WHEN d.[Provider Organization Name (Legal Business Name)] != '' THEN d.[Provider Organization Name (Legal Business Name)]
				ELSE dbo.fullName(d.[Provider Last Name (Legal Name)], d.[Provider First Name], '')
			END AS ProviderName
			,a.[MemberID]
			,a.[MemberFirstName]
			,a.[MemberLastName]
			,a.[DOB]
			,a.[IsTestDue] as Compliant
			,a.[LOB]
			,a.[SDA] as ServiceArea
			,CASE
				WHEN ISNULL(e.HomePhone, '') = '' THEN e.CellPhone
				ELSE e.HomePhone
			END AS [Phone Number]
		FROM [dbo].[Final_HEDIS_Member_FULL] a
		JOIN [dbo].[HedisSubmeasures] b ON a.[TestID] = b.ID
		JOIN [dbo].[HedisMeasures] c ON b.MeasureID = c.ID
		JOIN [dbo].[HedisScorecard] f ON b.ID = f.SubmeasureID AND f.CustID = @CustID
		LEFT JOIN [dbo].[HedisScorecard_TIN] g ON f.ID = g.ScoreCardID AND (ISNULL(g.TIN, 0) = @TIN)
		LEFT JOIN [dbo].[LookupNPI] d ON a.PCP_NPI = d.NPI
		LEFT JOIN dbo.MainPersonalDetails e ON a.MVDID = e.ICENUMBER
		WHERE a.CustID = @CustID
			AND a.[PCP_TIN] = @TIN
			AND a.MonthID = @MonthID
			AND (ISNULL(f.DRLink_Active, 0) = 1 OR ISNULL(g.DRLink_Active, 0) = 1)
			AND a.LOB = (CASE
							WHEN (@LOB = 'ALL') THEN a.LOB
							ELSE @LOB
						END)
			AND a.PCP_NPI = (CASE
							WHEN (@NPI = 'ALL') THEN a.PCP_NPI
							ELSE @NPI
						END)
		ORDER BY MeasureAbbreviation, SubMeasureAbbreviation, ProviderName, [MemberLastName], [MemberFirstName]
	END
END