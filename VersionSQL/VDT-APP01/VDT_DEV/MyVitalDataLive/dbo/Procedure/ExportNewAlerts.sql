/****** Object:  Procedure [dbo].[ExportNewAlerts]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 4/13/2012
-- Description:	Creates text file with recently created alerts. File is comma separated
-- =============================================
CREATE PROCEDURE [dbo].[ExportNewAlerts]
AS
BEGIN
	SET NOCOUNT ON;

	declare @lastExport datetime, @amerigroupCustID int, @parklandCustID int
	declare @result varchar(max), @fileName varchar(50),@curDate varchar(10),
		@header varchar(1000), @recordCount int
		
	declare @temp table (
		MedicaidID varchar(50),
		FirstName varchar(50),
		LastName varchar(50),
		HomePhone varchar(50), 
		AlertDate varchar(50), 
		FacilityName varchar(50),
		FacilityNPI varchar(50),
		PCP_NPI varchar(50)
	)

	select @curDate = CONVERT(varchar(10), getdate(), 101)
	
	select @header = 
		'MEDICAID_ID,MEMBER_FIRSTNAME,MEMBER_LASTNAME,MEMBER_PHONE,MEMBER_PCP_NPI,ALERT_DATE,FACILITY_NAME,FACILITY_NPI'
		+ CHAR(10)

	select @result = @header, @fileName = ''
	
	set @fileName = 'ERAlerts_' 
		+ left(@curDate,2)
		+ substring(@curDate,4,2)
		+ right(@curDate,4)
		+ '.csv'
	
	select @amerigroupCustID = Cust_ID
	from HPCustomer
	where Name = 'Amerigroup' and ParentID is null


	select @parklandCustID = Cust_ID
	from HPCustomer
	where Name = 'Parkland' and ParentID is null
	
	select @lastExport = MAX(exportdate)
	from dbo.ExportNewAlertsLog
	where success = 1
	
	--select @lastExport, @amerigroupCustID, @parklandCustID
	
	if(@lastExport is null)
	begin
		set @lastExport = DATEADD(DAY,-1,GETUTCDATE())
	end

	--select @lastExport

	insert into @temp(MedicaidID,
		FirstName,
		LastName,
		HomePhone, 
		AlertDate, 
		FacilityName,
		FacilityNPI,
		PCP_NPI)
	select distinct isnull((
			select top 1 Medicaid from MainInsurance where ICENUMBER = li.MVDId
		),'') as MedicaidID,
		isnull(p.FirstName,''),
		isnull(p.LastName,''),
		isnull(p.HomePhone,''), 
		isnull( convert(varchar(10),a.AlertDate,101) + ' ' + right(convert(varchar, a.AlertDate, 120),8),''), 
		isnull(e.FacilityName,''),
		isnull(e.FacilityNPI,''),
		isnull(s.NPI,'') as PCP_NPI
	from HPAlert a
		inner join EDVisitHistory e on a.RecordAccessID = e.SourceRecordID
		inner join Link_MVDID_CustID li on a.MemberID = li.InsMemberId
		inner join MainPersonalDetails p on li.MVDId = p.ICENUMBER
		inner join MainSpecialist s on li.MVDId = s.ICENUMBER
	where AlertDate > @lastExport
		and s.RoleID = 1
		and s.NPI in
		(
			select mg.NPI from Link_MDGroupNPI mg
		)
		and li.Cust_ID in(@amerigroupCustID, @parklandCustID)
		
	--select *
	--from @temp

	select @result = @result + MedicaidID + ',' +
		FirstName + ',' +
		LastName + ',' +
		HomePhone + ',' + 
		PCP_NPI + ',' +
		AlertDate + ',' +
		FacilityName + ',' +
		FacilityNPI +
		CHAR(10)
	from @temp
	
	select @recordCount = COUNT(medicaidID)
	from @temp
	
	--select @result
	--select @fileName
	
	EXEC WriteStringToFile
		@String = @result,
		@Path = '\\vitaldataweb01\c$\sftproot\MiDoctors',
		@Filename = @fileName

--		@Path = 'Z:\Outbound',
		
	insert into ExportNewAlertsLog(ExportDate,Filename,RecordCount,Note,Success)
	values(GETUTCDATE(),@fileName,@recordCount,'',1)
END