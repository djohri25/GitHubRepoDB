/****** Object:  Procedure [dbo].[Get_FormCMFWAssessmentByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name> FormCMFWAssessment
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================[Get_FormCMFWAssessmentByID]
CREATE PROCEDURE [dbo].[Get_FormCMFWAssessmentByID]
@ID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1[ID]
      ,F.[MVDID]
      ,F.[CustID]
      ,F.[StaffInterviewing]
      ,F.[FormDate]
      ,F.[Gender]
      ,F.[DateOfBirth]
      ,F.[PLan]
      ,F.[ProviderIDNumber]
      ,F.[Address]
      ,F.[City]
      ,F.[State]
      ,F.[Zip]
      ,F.[MemberPhone]
      ,F.[MemberOtherPhone]
      ,F.[MemberExt]
      ,F.[MemberEmail]
      ,F.[ParentLegalGuardian]
      ,F.[GuardianPhone]
		,[GuardianOtherPhone]
		,[GuardianExt]
		,[IntroductionOfCMRole]
		,[MemberAgreeToCMservices]
		,[CMServicesReason],
		[PrimaryCareProvider],
		[ProviderContactNumber],
		[DateofLastVisit],
		[MigrantFarmerworker],
		[AnyAssistance],
		[SpecialNotes],
		d.FirstName,
		d.LastName
  FROM [FormCMFWAssessment] F
  Left JOIN MainPersonalDetails d ON d.ICENUMBER = F.MVDID
  LEFT JOIN MainInsurance m ON m.ICENUMBER = F.MVDID 
  where F.ID = @ID
  order by f.FormDate desc
END