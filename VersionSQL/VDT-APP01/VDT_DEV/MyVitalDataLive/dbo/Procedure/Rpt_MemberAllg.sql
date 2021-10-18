/****** Object:  Procedure [dbo].[Rpt_MemberAllg]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Rpt_MemberAllg] 

	@ICENUMBER varchar(30)
AS


  -- =============================================
-- Author:		John Patrick "JP" Gregorio
-- Create date: 07/16/2019
-- Description: Find Allergies Entered for the member
-- Notes: Currently not populated. Needs mechanisms to map from MainAllergies to ComputedMemberAllergies
-- Exec dbo.[Rpt_MemberAllg] '1695536802720B68'
  -- =============================================

SET NOCOUNT ON

SELECT (SELECT AllergenTypeName FROM LookupAllergies
	WHERE ma.AllergenTypeId = LookupAllergies.AllergenTypeId) AS TypeName,
	dbo.InitCap(ma.AllergenName) as AllergenName, 
	Reaction,
	ISNULL(CreatedBy,'') as CreatedBy,
	ISNULL(CreatedByOrganization,'') as CreatedByOrganization,
	ISNULL(UpdatedBy,'') as UpdatedBy,
	ISNULL(UpdatedByOrganization,'') as UpdatedByOrganization,
	ISNULL(UpdatedByContact,'') as UpdatedByContact
FROM ComputedMemberAllergies ma
WHERE ICENUMBER = @ICENUMBER 
ORDER BY RecordNumber