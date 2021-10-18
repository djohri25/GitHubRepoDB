/****** Object:  Procedure [dbo].[Get_MDPatientExportData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 4/29/2014
-- Description:	Retrieve member data used to export
-- Changes: 05/08/2018	MDeLuca	Added: AND b.LOB IS NULL
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDPatientExportData]
	@MVDIDList varchar(max),
	@User varchar(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	--declare @MVDIDList varchar(max)
	--select @MVDIDList = 'BL199628,AW969785,MM673369'
  
    DECLARE @tempmvd table (mvdid varchar(20))
    DECLARE @VisitCountDateRange datetime
	DECLARE @CustID int

	--CustID
	SELECT DISTINCT @CustID = CustID_Import
	FROM [dbo].[MDUser] a
	JOIN [Link_MDAccountGroup] b ON a.ID = b.MDAccountID
	JOIN MDGroup c ON b.mdGroupID = c.ID
	WHERE username = @User
    
    SET @VisitCountDateRange = DATEADD(mm, -6, GETDATE())
    
	INSERT INTO @tempmvd(mvdid)
	SELECT * FROM dbo.Split(@mvdIDList, ',')
	
	SELECT p.FirstName, p.LastName, CONVERT(varchar, p.DOB, 101) AS 'DOB',
		CASE p.genderID
			WHEN '1' THEN 'M'
			WHEN '2' THEN 'F'
			ELSE ''
		END AS Gender,
		p.HomePhone,
		p.Address1,
		p.Address2,
		p.City,
		p.State,
		p.PostalCode,
		(SELECT TOP 1 Medicaid FROM MainInsurance WHERE ICENUMBER = t.mvdid) AS Medicaid,
		(SELECT COUNT(id) FROM EDVisitHistory v WHERE v.ICENUMBER = t.mvdid AND v.VisitType = 'ER' AND v.visitdate > @VisitCountDateRange) AS ERVisitCount,
		SUBSTRING((SELECT DISTINCT ',' + CAST(hm.Abbreviation AS varchar(10)) 
					   FROM [Final_HEDIS_Member] h
					   JOIN [HedisSubmeasures] s ON h.TestID = s.id
					   JOIN [HedisMeasures] hm ON hm.ID = s.MeasureID
					   JOIN [dbo].[HedisScorecard] hs ON hs.SubmeasureID = s.ID AND hs.CustID = @CustID AND hs.LOB IS NULL
					   LEFT JOIN [dbo].[HedisScorecard_TIN] d ON hs.ID = d.ScoreCardID AND ISNULL(d.TIN, 0) = h.PCP_TIN
					   WHERE h.CustID = @CustID
							AND h.MVDID = t.MVDID
							AND (ISNULL(hs.DRLink_Active, 0) = 1 OR ISNULL(d.DRLink_Active, 0) = 1)
					FOR XML PATH('')), 2, 200000) AS TestDueList
	FROM @tempmvd t
	INNER JOIN MainPersonalDetails p ON t.mvdid = p.ICENUMBER
END