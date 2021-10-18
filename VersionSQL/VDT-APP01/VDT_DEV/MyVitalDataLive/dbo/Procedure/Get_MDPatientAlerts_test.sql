/****** Object:  Procedure [dbo].[Get_MDPatientAlerts_test]    Committed by VersionSQL https://www.versionsql.com ******/

--DROP PROCEDURE[dbo].[Get_MDPatientAlerts_test] 

-- =============================================
-- Author:		sw
-- Create date: 8/11/2009
-- Description:	Returns doctor's alerts for all patients
--	If @PatientMVDID is valued, return alerts only for specific patient
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDPatientAlerts_test] 
	@DoctorID varchar(20),
	@PatientMVDID varchar(20),
	@DateRange int = null,
	@EMS varchar(50) = null,
	@UserID_SSO varchar(50) = null,
	@Page int,
	@RecsPerPage int
AS
BEGIN
	SET NOCOUNT ON;

	declare @tempRange datetime, @VisitCountDateRange datetime
		

select  @PatientMVDID


	select @tempRange = '01/01/1950',
		@VisitCountDateRange = dateadd(mm,-6,getdate())




	if(@DateRange is not null AND @DateRange <> 0)
	begin
		select @tempRange = CAST(DATEADD(DD,-@DateRange,getdate()) AS DATE)
	END

SELECT @tempRange


	
	select   COUNT (*) OVER () AS TotalRecords, v.ID, isnull(p.firstname,'') + isnull(' ' + p.lastname,'') as Name
			,v.HPCustName as hpName
			,v.InsMemberID	as InsMemberID	
			,p.icenumber as mvdid
			,CONVERT(VARCHAR(10),v.AlertDate ,101) as Date
			,v.Facility
			,upper(substring(v.ChiefComplaint,1,1))+lower(substring(v.ChiefComplaint,2,len(v.ChiefComplaint))) as ChiefComplaint
						
			,upper(substring(v.EMSNote,1,1))+lower(substring(v.EMSNote,2,len(v.EMSNote))) as Notes
			
			,(select top 1 s.NPI from MainSpecialist s where s.ICENUMBER = p.ICENUMBER and RoleID =1 order by s.ModifyDate desc) as PCP_NPI
			,(select COUNT(id) from EDVisitHistory e where e.ICENUMBER = v.mvdid and e.VisitType = 'ER' and e.visitdate > @VisitCountDateRange) as ERVisitCount      
	from MDMemberVisit v
		inner join MainPersonalDetails p on v.MVDID = p.ICENUMBER		
	where 
		CAST(v.AlertDate AS DATE) >= @tempRange
		AND		
		p.ICENUMBER =
		(
			Case ISNULL(@PatientMVDID,'')
				when '' then p.ICENUMBER
				else @PatientMVDID
			end
		)
		AND MVDID in(
			select s.ICENUMBER
			from MDUser u
				inner join Link_MDAccountGroup ag on u.ID = ag.MDAccountID
				inner join MDGroup g on ag.MDGroupID = g.ID
				inner join Link_MDGroupNPI n on g.ID = n.MDGroupID
				inner join MainSpecialist s on n.NPI = s.NPI
			where u.Username = @DoctorID
				and s.RoleID = 1
			)
	--order by v.AlertDate desc
	--OFFSET (@Page-1)*@RecsPerPage ROWS FETCH NEXT @RecsPerPage ROWS ONLY
	
	---- Record SP Log
	--declare @params nvarchar(1000) = null
	--set @params = '@DoctorID=' + ISNULL(@DoctorID, 'null') + ';' +
	--			  '@PatientMVDID=' + ISNULL(@PatientMVDID, 'null') + ';' +
	--			  '@DateRange=' + CONVERT(varchar(50), @DateRange) + ';'
	--exec [dbo].[Set_StoredProcedures_Log] '[dbo].[Get_MDPatientAlerts]', @EMS, @UserID_SSO, @params

	
END