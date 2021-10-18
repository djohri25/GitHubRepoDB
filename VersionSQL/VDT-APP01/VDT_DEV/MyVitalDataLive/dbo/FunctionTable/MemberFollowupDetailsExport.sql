/****** Object:  Function [dbo].[MemberFollowupDetailsExport]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[MemberFollowupDetailsExport]
	(
		@custID int,
		@begin	datetime,
		@end	datetime	
	)
RETURNS @result TABLE
	(
		MemberID varchar(15) NULL,
		MemberFirstName varchar(32) NOT NULL,
		MemberLastName varchar(32) NOT NULL,
		FacilityName varchar(50) NOT NULL,
		FacilityNPI varchar(10) NOT NULL,
		DateVisited datetime NOT NULL,
		DateCalled datetime NOT NULL,
		IsComplete bit NOT NULL,
		YN1 tinyint NULL,
		MC2 tinyint NULL,
		YN4 tinyint NULL,
		YN5 tinyint NULL,
		MC6 tinyint NULL,
		YN7 tinyint NULL,
		YN8 tinyint NULL,
		YN9 tinyint NULL,
		YN10 tinyint NULL,
		YN11 tinyint NULL,
		YN12 tinyint NULL,
		Text3 text NULL,
		Text6 text NULL,
		Text12 text NULL,
		ModifiedBy varchar(50) NOT NULL,
		DateCreated datetime NOT NULL
	)
AS
BEGIN
	IF @custID IS NULL
	BEGIN
		INSERT INTO @result
		SELECT	a.MemberID, a.PatientFirstName AS MemberFirstName, a.PatientLastName AS MemberLastName, 
				b.Name AS FacilityName, b.NPI AS FacilityNPI, a.DateVisited, a.DateCalled, a.IsComplete, 
				a.YN1, a.MC2, a.YN4, a.YN5, a.MC6, a.YN7, a.YN8, a.YN9, a.YN10, a.YN11, a.YN12, a.Text3, a.Text6, a.Text12, 
				a.ModifiedBy, a.DateCreated
		FROM	PatientFollowupDetails AS a INNER JOIN 
				MainEMSHospital AS b ON a.FacilityID = b.ID
		WHERE	CustID IS NULL AND DateCreated BETWEEN @begin AND @end
	END
	ELSE
	BEGIN
		INSERT INTO @result
		SELECT	a.MemberID, a.PatientFirstName AS MemberFirstName, a.PatientLastName AS MemberLastName, 
				b.Name AS FacilityName, b.NPI AS FacilityNPI, a.DateVisited, a.DateCalled, a.IsComplete, 
				a.YN1, a.MC2, a.YN4, a.YN5, a.MC6, a.YN7, a.YN8, a.YN9, a.YN10, a.YN11, a.YN12, a.Text3, a.Text6, a.Text12, 
				a.ModifiedBy, a.DateCreated
		FROM	PatientFollowupDetails AS a INNER JOIN 
				MainEMSHospital AS b ON a.FacilityID = b.ID
		WHERE	CustID = @custID AND DateCreated BETWEEN @begin AND @end
	END
	RETURN
END