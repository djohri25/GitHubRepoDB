/****** Object:  Procedure [dbo].[Sly_EliminateDuplicate_ER_visits]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/29/2015
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Sly_EliminateDuplicate_ER_visits]
AS
BEGIN

	SET NOCOUNT ON;


declare @mvdid varchar(20), @visitdate date, @mainNPI varchar(20), @dischargeRecordID int, @result bit, @id int,
	@facilityname varchar(100), @physicianPhone varchar(50), @source varchar(50), @sourceRecordID varchar(50), @isHospitalAdmit bit, @facilityNPI varchar(50),@pos varchar(50)

declare @temp table(id int, facilityname varchar(100), physicianPhone varchar(50), source varchar(50), sourceRecordID varchar(50), isHospitalAdmit bit, facilityNPI varchar(50), pos varchar(50))

--declare @myCounter int

--set @myCounter = 0

while   exists(select top 1 *
		from Sly_DuplicateER_Visit
		where IsProcessed = 0 and processAttemptCount = 0)
begin
	select top 1 @id =id, @mvdid = MVDID, @visitdate = VisitDate
	from Sly_DuplicateER_Visit
	where IsProcessed = 0 and processAttemptCount = 0

--select @myCounter = @myCounter + 1

	-- Reset variables
	select  @result = 0, @mainNPI = null, @dischargeRecordID = null,
		@facilityname = null, @physicianPhone = null, @source = null, @sourceRecordID = null, @isHospitalAdmit = null, @facilityNPI= null,@pos= null

	insert into @temp(id, facilityname, physicianPhone, source, sourceRecordID, isHospitalAdmit, facilityNPI, pos)
	select id, facilityname, physicianPhone, source, sourceRecordID, isHospitalAdmit, facilityNPI, pos
	from EDVisitHistory
	where ICENUMBER = @mvdid
		and convert(date,VisitDate)  = @visitdate
		and VisitType = 'ER'

	--select *
	--from EDVisitHistory
	--where ICENUMBER = @mvdid
	--	and convert(date,VisitDate)  = @visitdate
	--	and VisitType = 'ER'

	--select * from @temp

	if exists( select top 1 *
		from @temp t
		where t.source = 'Discharge Data' and ISNULL(facilityNPI,'') <> ''
	)
	begin

		-- in claims but not discharge: physicianPhone, isHospitalAdmit, pos

		select @mainNPI = facilityNPI, @dischargeRecordID = id
		from @temp t
		where t.source = 'Discharge Data' and ISNULL(facilityNPI,'') <> ''

		select top 1  
			@facilityname = facilityname, 
			@physicianPhone = physicianPhone, 
			@source = source, 
			@sourceRecordID = sourceRecordID, 
			@isHospitalAdmit = isHospitalAdmit, 
			@facilityNPI = facilityNPI,
			@pos = pos
		from @temp t
			inner join DischargeReportFacility f on t.facilityNPI = f.AssociatedNPI
		where t.source like  '%claim%'
			and f.MainNPI = @mainNPI

		if( @sourceRecordID is not null)
		begin
			update EDVisitHistory
				set 
					PhysicianPhone = 
						case 
							when isnull(physicianPhone,'') = '' then @physicianPhone
							else PhysicianPhone
						end,
					IsHospitalAdmit = 
						case 
							when isnull(IsHospitalAdmit,'') = '' then @isHospitalAdmit
							else IsHospitalAdmit
						end,
					POS = 
						case 
							when isnull(POS,'') = '' then @POS
							else POS
						end,
					MatchName = @source,
					MatchRecordID = @sourceRecordID
			where id = @dischargeRecordID

			--select distinct '@claimRecordID want to delete', t.id
			--from @temp t
			--	inner join DischargeReportFacility f on t.facilityNPI = f.AssociatedNPI
			--where t.source like  '%claim%'
			--	and f.MainNPI = @mainNPI

			delete from EDVisitHistory
			where ICENUMBER = @mvdid
				and id in
				(
					select t.id
					from @temp t
						inner join DischargeReportFacility f on t.facilityNPI = f.AssociatedNPI
					where t.source like  '%claim%'
						and f.MainNPI = @mainNPI
				)

			select @result = 1
		end

	end

	if(@result = 1)
	begin
		update Sly_DuplicateER_Visit
		set IsProcessed = 1,
			processDate = getdate()
		where id = @id
	end
	else
	begin
		update Sly_DuplicateER_Visit
		set ProcessAttemptCount = 1
		where id = @id
	end

	delete from @temp

	--select *
	--from EDVisitHistory
	--where ICENUMBER = @mvdid
	--	and convert(date,VisitDate)  = @visitdate
	--	and VisitType = 'ER'

end -- END while


END