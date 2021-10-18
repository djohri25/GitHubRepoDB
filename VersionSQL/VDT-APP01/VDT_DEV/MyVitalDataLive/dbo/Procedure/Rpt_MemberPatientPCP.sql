/****** Object:  Procedure [dbo].[Rpt_MemberPatientPCP]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		John Patrick "JP" Gregorio
-- Create date: 07/09/2019
-- Description: Find PCP Info for a specific member
-- Exec dbo.[Rpt_MemberPatientPCP] '1610000001BA4530B'
-- =============================================

CREATE Procedure [dbo].[Rpt_MemberPatientPCP] 
	@IceNumber varchar(30)
As

	SET NOCOUNT ON;

-- Get Latest Eligibility Info with PCP
Select
AffiliationID as MedicalGroup
,dbo.fnFullName(left([ProviderLastName],50), [ProviderFirstName], NULL) as 'Name'
,dbo.fnInitCap( isnull(LEFT([ServiceAddress1],50) + ' ','') 
+ isnull(LEFT([ServiceAddress2],50),'')) as address1
,dbo.fnInitCap(isnull([ServiceCity],'')) 
+ upper(isnull(', ' + LEFT([ServiceState],2) + ' ','')) 
+ isnull(left([ServiceZip],5),'') as address2
,dbo.fnFormatPhone([ServicePhone]) as Phone
,dbo.fnFormatPhone([ServiceFax]) as Fax
,Replace(LTrim(RTrim(IsNULL(Language1,'')+' '+IsNULL(Language2,'')+' '+IsNULL(Language3,''))), ' ', ', ') as languages
,'' as 'mon'
,'' as 'tues'
,'' as 'wed'
,'' as 'thu'
,'' as 'fri'
,'' as 'sat'
,'' as 'sun'
,'' as notSetNote	
From dbo.FinalEligibility a
Inner Join (Select MVDID, max(MemberEffectiveDate) as MemberEffectiveDate, LOB From dbo.FinalEligibility Group by MVDID, LOB) b 
on a.MVDID = b.MVDID and a.MemberEffectiveDate = b.MemberEffectiveDate and a.LOB = b.LOB
Outer Apply (Select Top 1 * From dbo.FinalProvider c where a.PCPNPI=c.NPI Order by AffiliationEffectiveDate desc) RPN
Where a.PCPNPI is not null and a.MVDID = @ICENUMBER


/*
	declare @pcpNPI varchar(50),
		@languageList varchar(200),
		@notSetNote varchar(1000),
		@pcpRoleName varchar(50)

	set @languageList = ''
	set @pcpRoleName = 'Primary Care Physician'

	select top 1 @pcpNPI = NPI 
	from mainspecialist s
		inner join lookuproleID r on s.roleID = r.roleID
	where s.icenumber = @IceNumber
		and r.roleName = @pcpRoleName

	if exists(select npi from lookupNPI_Custom where npi = @pcpNPI)
	begin
		select @languageList = @languageList + l.Name + ', '
		from dbo.PersonLanguagesSpoken s
			inner join lookupLanguage l on s.languageID = l.ID
		where s.PersonID = @pcpNPI and PersonCategory = 'Provider'

		if(len(isnull(@languageList,'')) > 2)
		begin
			set @languageList = substring(@languageList, 0, len(@languageList))
		end

		select MedicalGroup, 
			dbo.fnFullName(left([Provider Last Name (Legal Name)],50), [Provider First Name], [Provider Middle Name]) + ' ' + isnull([Provider Credential Text],'') as 'Name',
			dbo.fnInitCap( isnull(LEFT([Provider First Line Business Practice Location Address],50) + ' ','') 
				+ isnull(LEFT([Provider Second Line Business Practice Location Address],50),'')) as address1,
			dbo.fnInitCap(isnull([Provider Business Practice Location Address City Name],'')) 
				+ upper(isnull(', ' + LEFT([Provider Business Practice Location Address State Name],2) + ' ','')) 
				+ isnull(left([Provider Business Practice Location Address Postal Code],5),'') as address2,
			dbo.fnFormatPhone([Provider Business Practice Location Address Telephone Number]) as Phone,
			dbo.fnFormatPhone([Provider Business Practice Location Address Fax Number]) as Fax,
			@languageList as languages,
			OfficeHrMon as 'mon',
			OfficeHrTue as 'tues',
			OfficeHrWed as 'wed',
			OfficeHrThu as 'thu',
			OfficeHrFri as 'fri',
			OfficeHrSat as 'sat',
			OfficeHrSun as 'sun',
			'' as notSetNote	
		from lookupNPI_Custom 
		where npi = @pcpNPI
	end
	else if exists (select s.icenumber
		from mainspecialist s
			inner join lookuproleID r on s.roleID = r.roleID
		where s.icenumber = @IceNumber and r.roleName = @pcpRoleName)
	begin
		select top 1 '' as MedicalGroup, 
			dbo.fnFullName(lastName, FirstName, '') as 'Name',
			dbo.fnInitCap( isnull(address1 + ' ','') 
				+ isnull(address2,'')) as address1,
			dbo.fnInitCap(isnull(city,'')) 
					+ upper(isnull(', ' + state + ' ','')) 
				+ isnull(Postal,'') as address2,
			dbo.fnFormatPhone(phone) as Phone,
			dbo.fnFormatPhone(faxPhone) as Fax,
			@languageList as languages,
			'' as 'mon',
			'' as 'tues',
			'' as 'wed',
			'' as 'thu',
			'' as 'fri',
			'' as 'sat',
			'' as 'sun',
			'' as notSetNote	
		from mainspecialist s
			inner join lookuproleID r on s.roleID = r.roleID
		where s.icenumber = @IceNumber and r.roleName = @pcpRoleName
	end
	else if exists(select npi from dbo.lookupNPI where npi = @pcpNPI)
	begin
		select '' as MedicalGroup, 
			dbo.fnFullName(left([Provider Last Name (Legal Name)],50), [Provider First Name], [Provider Middle Name]) + ' ' + isnull([Provider Credential Text],'') as 'Name',
			dbo.fnInitCap( isnull(LEFT([Provider First Line Business Practice Location Address],50) + ' ','') 
				+ isnull(LEFT([Provider Second Line Business Practice Location Address],50),'')) as address1,
			dbo.fnInitCap(isnull([Provider Business Practice Location Address City Name],'')) 
				+ upper(isnull(', ' + LEFT([Provider Business Practice Location Address State Name],2) + ' ','')) 
				+ isnull(left([Provider Business Practice Location Address Postal Code],5),'') as address2,
			dbo.fnFormatPhone([Provider Business Practice Location Address Telephone Number]) as Phone,
			dbo.fnFormatPhone([Provider Business Practice Location Address Fax Number]) as Fax,
			@languageList as languages,
			'' as 'mon',
			'' as 'tues',
			'' as 'wed',
			'' as 'thu',
			'' as 'fri',
			'' as 'sat',
			'' as 'sun',
			'' as notSetNote	
		from dbo.lookupNPI 
		where npi = @pcpNPI
	end
	else if exists (select mvdid from Link_MemberId_MVD_Ins where mvdid = @icenumber)
	begin
		select @notSetNote = PCPNotSetNote
		from Link_MVDID_CustID li
			inner join hpcustomer c on li.cust_id = c.cust_id
		where li.mvdid = @icenumber

		select '' as MedicalGroup, 
			'' as 'Name',
			'' as address1,
			'' as address2,
			'' as Phone,
			'' as Fax,
			'' as languages,
			'' as 'mon',
			'' as 'tues',
			'' as 'wed',
			'' as 'thu',
			'' as 'fri',
			'' as 'sat',
			'' as 'sun',
			@notSetNote as notSetNote		
	end
*/