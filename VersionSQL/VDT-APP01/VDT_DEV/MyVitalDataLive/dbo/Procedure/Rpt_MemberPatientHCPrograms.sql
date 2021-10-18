/****** Object:  Procedure [dbo].[Rpt_MemberPatientHCPrograms]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Rpt_MemberPatientHCPrograms]
	@IceNumber varchar(15)
As
	declare @note varchar(1000)

	select p.Name, (dbo.FormatPhone(p.phone)) as phone,
			Description as ProgramDescription,
			HealthcareProgramsSectionDesc as 'Note'
	from dbo.Link_MVDID_CustID li
		inner join hpCustomer c on li.cust_id = c.cust_id
		inner join dbo.HPHealthcareProgram p on li.cust_id = p.cust_id
	where mvdid = @IceNumber