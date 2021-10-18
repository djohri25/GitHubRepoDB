/****** Object:  Procedure [dbo].[Sly_EliminateDuplicate_ER_visits_CreatedFromClaims]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/29/2015
-- Description:	eliminate ER visits created based on claim records
-- =============================================
CREATE PROCEDURE [dbo].[Sly_EliminateDuplicate_ER_visits_CreatedFromClaims]
AS
BEGIN

	SET NOCOUNT ON;


declare @mvdid varchar(20), @visitdate date, @mainNPI varchar(20), @dischargeRecordID int, @result bit, @id int,
	@facilityname varchar(100), @physicianPhone varchar(50), @source varchar(50), @sourceRecordID varchar(50), 
	@isHospitalAdmit bit, @facilityNPI varchar(50),@pos varchar(50), @claimNumber varchar(50), @curTempID int

declare @temp table(id int, visitDate date, facilityname varchar(100), physicianPhone varchar(50), 
	source varchar(50), sourceRecordID varchar(50), isHospitalAdmit bit, facilityNPI varchar(50), pos varchar(50), claimNumber varchar(50))

declare @myCounter int

set @myCounter = 0

-- @myCounter < 10

while exists(select top 1 *
		from Sly_DuplicateER_Visit
		where IsProcessed = 0 and processAttemptCount = 0)
begin
	select top 1 @id =id, @mvdid = MVDID, @visitdate = VisitDate
	from Sly_DuplicateER_Visit
	where IsProcessed = 0 and processAttemptCount = 0

select @myCounter = @myCounter + 1

	-- Reset variables
	select  @result = 0, @mainNPI = null, @dischargeRecordID = null,
		@facilityname = null, @physicianPhone = null, @source = null, @sourceRecordID = null, @isHospitalAdmit = null, @facilityNPI= null,@pos= null

	insert into @temp(id, visitDate, facilityname, facilityNPI, source, sourceRecordID, claimNumber)
	select e.id, VisitDate, facilityname, FacilityNPI, source, sourceRecordID, c.[Claim Number]
	from EDVisitHistory e
		inner join [VD-RPT01].hpm_import.dbo.claims c on e.SourceRecordID = c.ID
	where ICENUMBER = @mvdid
		and convert(date,VisitDate)  = @visitdate
		and VisitType = 'ER'
		and Source like '%claim%'
	order by e.Created desc

	--select *
	--from EDVisitHistory e
	--	inner join [VD-RPT01].hpm_import.dbo.claims c on e.SourceRecordID = c.ID
	--where ICENUMBER = @mvdid
	--	and convert(date,VisitDate)  = @visitdate
	--	and VisitType = 'ER'
	--	and Source like '%claim%'
	--order by e.Created desc

	--select *
	--from EDVisitHistory
	--where ICENUMBER = @mvdid
	--	and convert(date,VisitDate)  = @visitdate
	--	and VisitType = 'ER'

	--select * from @temp

	while exists(select top 1 * from @temp where facilityNPI is not null)
	begin
		select top 1 @curTempID = id, @claimNumber = claimNumber 
		from @temp
		where facilityNPI is not null

		if exists (select top 1 * from @temp where claimNumber = @claimNumber and id <> @curTempID)
		begin
			--select @curTempID as 'Current ID. Deleting following',* from @temp where claimNumber = @claimNumber and id <> @curTempID 

			delete from EDVisitHistory where id in
			(
				select id from @temp where claimNumber = @claimNumber and id <> @curTempID
			)

			delete from @temp where claimNumber = @claimNumber and id <> @curTempID
		end

		--select * from @temp
				
		delete from @temp where id = @curTempID
	end

	delete from @temp

	--select *
	--from EDVisitHistory e
	--	inner join [VD-RPT01].hpm_import.dbo.claims c on e.SourceRecordID = c.ID
	--where ICENUMBER = @mvdid
	--	and convert(date,VisitDate)  = @visitdate
	--	and VisitType = 'ER'
	--	and Source like '%claim%'
	--order by e.Created desc

	update Sly_DuplicateER_Visit
	set IsProcessed = 1, ProcessDate = getdate()
	where ID = @id 
end -- END while


END