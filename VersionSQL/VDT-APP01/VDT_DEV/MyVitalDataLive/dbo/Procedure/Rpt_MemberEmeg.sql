/****** Object:  Procedure [dbo].[Rpt_MemberEmeg]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Rpt_MemberEmeg]

	@ICENUMBER varchar(30)
AS

  -- =============================================
-- Author:		John Patrick "JP" Gregorio
-- Create date: 07/16/2019
-- Description: Find Emergency Contact Info for Member
-- Notes: Currently not populated. Needs mechanisms to map from MainCareInfo to ComputedMemberCareInfo
-- Exec dbo.[Rpt_MemberEmeg] '1695536802720B68'
  -- =============================================

SET NOCOUNT ON

SELECT  dbo.fnFullName(LastName, FirstName, MiddleName) AS FullName, Address1, Address2,
	City, State, Postal, dbo.fnFormatPhone(PhoneHome) AS HPhone,
	dbo.fnInitCap(isnull(Address1 + ' ','') + isnull(Address2,'')) as address,
	dbo.fnInitCap(isnull(city + ', ','')) + upper(isnull(state + ' ','')) + isnull(postal,'') as cityStateZip,
	dbo.fnFormatPhone(PhoneHome) As PhoneHome,dbo.fnFormatPhone(PhoneCell) As PhoneCell,
	dbo.fnFormatPhone(PhoneOther) As PhoneOther,lower(EmailAddress) as EmailAddress,
	(SELECT CareTypeName FROM LookupCareTypeID 
	WHERE LookupCareTypeID.CareTypeID = mc.CareTypeID) AS CareName,
	(SELECT RelationshipName FROM LookupRelationshipID 
	WHERE LookupRelationshipID.RelationshipId = mc.RelationshipId) AS RelName,
	ISNULL(CreatedBy,'') as CreatedBy,
	ISNULL(CreatedByOrganization,'') as CreatedByOrganization,
	ISNULL(UpdatedBy,'') as UpdatedBy,
	ISNULL(UpdatedByOrganization,'') as UpdatedByOrganization,
	ISNULL(UpdatedByContact,'') as UpdatedByContact
FROM ComputedMemberCareInfo mc
WHERE ICENUMBER = @ICENUMBER