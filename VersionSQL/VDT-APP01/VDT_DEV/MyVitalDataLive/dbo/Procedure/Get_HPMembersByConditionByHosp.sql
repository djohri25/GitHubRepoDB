/****** Object:  Procedure [dbo].[Get_HPMembersByConditionByHosp]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 2/20/2012
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Get_HPMembersByConditionByHosp]
	@Condition varchar(50),
	@Hospital varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

--select @Condition = 1,
--	@HosID = 2

	declare @hospitalID int
	
	select @hospitalID = ID
	from MainEMSHospital 
	where Name = @Hospital

	select m.ID
      ,InsMemberID
      ,CustID
      ,@Hospital as Hospital
      ,MVDID
      ,FirstName
      ,LastName
      ,dbo.FullName(LastName,FirstName,'') as MemberName
      ,StatusID      
      ,s.Name as Status	
      ,PCPVisitCount
      ,ERVisitCount
      ,PCPVisitCountSinceContact
      ,ERVisitCountSinceContact
      ,CONVERT(varchar(10),LastContactDate,101) as LastContactDate
      ,CONVERT(varchar(20),dbo.ConvertUTCtoEST(ModifyDate)) as ModifyDate
      ,ModifiedByName
      ,LastContactByName
	from MemberDiagnosisSummaryByHosp m
		left join dbo.LookupHPMemberStatus s on m.StatusID = s.ID
	where HospitalID = @HospitalID
		and MVDID in
		(
			select icenumber from MainCondition 
			where Code in
			(
				select Code from Link_ConditionLookupCode where lookupID = @Condition
			)
		)	
END