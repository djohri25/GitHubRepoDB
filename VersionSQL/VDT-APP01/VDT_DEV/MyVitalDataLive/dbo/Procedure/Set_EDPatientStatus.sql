/****** Object:  Procedure [dbo].[Set_EDPatientStatus]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:      Tim Thein
-- Create date: 9/22/2009
-- Description: Inserts a row into EDPatientStatus.  If dateVisited is null 
-- and another matching row exists within the previous 24 hours, a row will 
-- not be inserted.
-- =============================================
CREATE PROCEDURE [dbo].[Set_EDPatientStatus]
	@userName varchar(50),
	@mvdId varchar(15) = NULL,
	@dateVisited datetime = NULL,
	@patientFirstName varchar(32) = NULL,
	@patientLastName varchar(32) = NULL,
	@memberId varchar(15) = NULL,
	@custId	int = NULL
AS
BEGIN
	DECLARE	@facilityID int,
			@matchingRows int

	SELECT	@facilityID = CompanyID
	FROM	MainEMS
	WHERE	username = @userName
			
	--if(@facilityID is null)
	--begin
	--	-- Hosp users can also add followup entries
	--	select @facilityID = companyID
	--	from HospitalUser
	--	where Username = @userName
	--end		
			
	-- if dateVisited is null, we can assume that this procedure is being called from SP_MVD_App_Record
	-- and mvdId is the only parameter being supplied.
	IF @dateVisited IS NULL AND @mvdId IS NOT NULL
	BEGIN
		SET @dateVisited = GETUTCDATE()
		SELECT	@matchingRows = COUNT(*)
		FROM	EDPatientStatus AS status INNER JOIN
				Link_MemberId_MVD_Ins AS link ON status.MemberID = link.InsMemberId
		WHERE	link.MVDId = @mvdId AND status.FacilityID = @facilityID AND status.DateVisited > DATEADD(mi, -1440, @dateVisited)
		IF @matchingRows > 0
			RETURN
		SELECT	@patientFirstName = FirstName, @patientLastName = LastName
		FROM	MainPersonalDetails
		WHERE	ICENUMBER = @mvdId
		INSERT	EDPatientStatus
				(FacilityID, MemberID, CustID, PatientFirstName, PatientLastName, ModifiedBy, DateVisited)
		SELECT	@facilityID, InsMemberId, Cust_ID, @patientFirstName, @patientLastName, @userName, @dateVisited
		FROM	Link_MVDID_CustID
		WHERE	MVDId = @mvdId
	END
	-- else, we can assume that this procedure is being called from ASP.Net and 
	-- only patientFirstName, patientLastName, memberId, custId, and dateVisited is supplied.
	IF @dateVisited IS NOT NULL AND @patientFirstName IS NOT NULL AND @patientLastName IS NOT NULL AND @custId IS NOT NULL
	BEGIN
		SET @dateVisited = dbo.ETtoUTC(@dateVisited)
		INSERT	EDPatientStatus
				(FacilityID, MemberID, CustID, PatientFirstName, PatientLastName, ModifiedBy, DateVisited)
		VALUES	(@facilityID, @memberId, @custId, @patientFirstName, @patientLastName, @userName, @dateVisited)
	END
END