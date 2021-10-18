/****** Object:  Procedure [dbo].[Get_HEDISSubmeasures_DRLink]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 03/22/2017
-- Description:	Returns HEDIS measures list for a specific member
-- Changes: 05/08/2018	MDeLuca	Added: AND hs.LOB IS NULL
-- =============================================
CREATE PROCEDURE [dbo].[Get_HEDISSubmeasures_DRLink]
(
	@CustID int = 0,
	@User varchar(50) = NULL,
	@MVDID varchar(50)
)
AS
BEGIN
	DECLARE @TestList varchar(max)
	DECLARE @MonthID char(6), @CustID_Import int

	--CustID
	SET @CustID_Import = @CustID
	IF (@CustID_Import = 0)
	BEGIN
		SELECT DISTINCT @CustID_Import = CustID_Import
		FROM [dbo].[MDUser] a
		JOIN [Link_MDAccountGroup] b ON a.ID = b.MDAccountID
		JOIN MDGroup c ON b.mdGroupID = c.ID
		WHERE username = @User
	END

	SELECT @MonthID = Max(MonthID)
	FROM [dbo].[Final_HEDIS_Member_FULL]
	WHERE CustID = @CustID_Import

	select @TestList = COALESCE(@TestList + ',' ,'') + s.Abbreviation
	FROM [Final_HEDIS_Member_FULL] h
	JOIN HedisSubmeasures s ON h.TestID = s.id
	JOIN HedisMeasures hm ON hm.ID = s.MeasureID
	JOIN [dbo].[HedisScorecard] hs ON hs.SubmeasureID = s.ID AND hs.CustID = @CustID_Import AND hs.LOB IS NULL
	LEFT JOIN [dbo].[HedisScorecard_TIN] d ON hs.ID = d.ScoreCardID AND ISNULL(d.TIN, 0) = h.PCP_TIN
	WHERE h.CustID = @CustID_Import
		AND H.MVDID = @MVDID
		AND H.MonthID = @MonthID
		AND (ISNULL(hs.DRLink_Active, 0) = 1 OR ISNULL(d.DRLink_Active, 0) = 1)
	
	SELECT @TestList AS HedisSubmeasures
END