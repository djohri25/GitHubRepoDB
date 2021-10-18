/****** Object:  Procedure [dbo].[uspGetMobileMemberPersonalDetailsByMVDID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		bray
-- Create date: 09/29/20210
-- Description:	Search active member personal details based on MVDID for mobile app.
-- =============================================
Create PROCEDURE [dbo].[uspGetMobileMemberPersonalDetailsByMVDID]
	@MVDID varchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select top 1
		fm.mvdid as MVDID,
		dbo.InitCap(ISNULL(fm.MemberFirstName,'')) as FirstName,
		dbo.InitCap(ISNULL(fm.MemberMiddleName,'')) as MiddleName,
		dbo.InitCap(ISNULL(fm.MemberLastName,'')) as LastName,
		ISNULL(fm.Gender,'') as Gender,
		ISNULL(fm.SSN,'') as SSN,
		fm.DateOfBirth as DOB,
		dbo.InitCap(ISNULL(fm.Address1,'')) AS Address1,
		dbo.InitCap(ISNULL(fm.Address2,'')) AS Address2,
		dbo.InitCap(ISNULL(fm.City,'')) AS City,
		ISNULL(fm.State,'') AS State,
		ISNULL(fm.Zipcode,'') AS Zipcode,
		ISNULL(fm.HomePhone,'') AS HomePhone,
		ISNULL(fm.WorkPhone,'') AS WorkPhone,
		ISNULL(fm.Fax,'') AS Fax,
		ISNULL(fm.Email,'') AS Email,
		dbo.InitCap(ISNULL(fm.Language,'')) AS Language,
		CASE	WHEN ISNULL(fm.Ethnicity, '') = '' then '' 
				WHEN ISNULL(ISNumeric(fm.Ethnicity), '') = 1 then (Select lr.RaceName from [dbo].[LookupRace] lr where ISNULL(fm.Ethnicity, '') = ISNULL(lr.RaceID, ''))
				ELSE ISNULL(Ethnicity, '') 
		END AS Ethnicity
		from finalmember fm
	where 
		fm.MVDID = @MVDID
END