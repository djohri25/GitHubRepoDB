/****** Object:  Procedure [dbo].[Get_OutgoingHPMAlerts]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_OutgoingHPMAlerts]

AS
BEGIN
	-- Convert time to EST (values are stored in UTC)
	SELECT 
		ID
		,CustomerID
		,RecipientEmail
		,InsMemberId
		,InsMemberFName
		,InsMemberLName
		,dbo.ConvertUTCtoEST(AccessDate) as AccessDate
		,NPI
		,FacilityName
		,ChiefComplaint
		,EMSNote
	FROM SendHP_Alert
	WHERE Status = 'PENDING'
END