/****** Object:  Procedure [dbo].[Get_CCREncounters]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 4/24/2009
-- Description:	Get Encounters for specified user
--	formated as XML according to CCR standard
--  If no Encounters exist on record return empty XML
-- =============================================
CREATE procedure [dbo].[Get_CCREncounters]
(
	@MVDId varchar(20),
	@EncounterNode xml output,
	@CurObjID int output			-- unique identifier of each object in CCR
)
AS
BEGIN

	DECLARE @startIdentity int, 
		@IsValid bit			-- 0 - when data owner info invalid, 1 - valid

	select @EncounterNode = ''

	set @startIdentity = @CurObjID + 1

	if exists (select icenumber from edvisithistory where ICENUMBER = @MVDId)
	begin

		CREATE TABLE #tempEncounter(
			ObjID int IDENTITY(1,1) NOT NULL,
			RecordNumber int,
			FacilityName varchar(50),
			PhysicianFirstName varchar(50),
			PhysicianLastName varchar(50),
			PhysicianPhoneName varchar(50),
			VisitDate datetime,
			ActorID int
		)

		-- Set identity to start from curObjID + 1
		-- Note: you cannot use variable for seed in create table , 
		-- that's why I have to reseed identity
		-- DBCC CHECKIDENT (#tempEncounter, reseed, @startIdentity )

		-- DBCC CHECKIDENT requires system admin permissions, use the following instead 
		SET IDENTITY_INSERT #tempEncounter ON
		INSERT INTO #tempEncounter (ObjID) -- This is your primary key field
		VALUES (@startIdentity - 1)
		SET IDENTITY_INSERT #tempEncounter OFF
		DELETE FROM #tempEncounter

		declare @RecordNumber int,
			@CreatedBy nvarchar(250),
			@CreatedByOrganization varchar(250),
			@CreatedByNPI varchar(20),
			@UpdatedBy nvarchar(250),
			@UpdatedByOrganization varchar(250),
			@UpdatedByNPI varchar(20),
			@UpdatedByContact nvarchar(64),
			@tempActorID varchar(6)

		-- Temp table is needed to assign Actor/Owner IDs
		insert into #tempEncounter(
			RecordNumber,
			FacilityName,
			PhysicianFirstName,
			PhysicianLastName,
			PhysicianPhoneName,
			VisitDate)
		select ID,
			FacilityName,
			PhysicianFirstName,
			PhysicianLastName,
			PhysicianPhone,
			VisitDate 
		from edvisithistory
		where ICENUMBER = @MVDId

		-- Assign Actor ID
		-- If same actor already exist in Actors table use his ID.
		-- Otherwise, generate a new ID and insert into actors table.

		while exists (select recordnumber from #tempEncounter where ActorID is null)
		begin
			-- Reset default value
			set @IsValid = 0

			select top 1 @RecordNumber = RecordNumber,
				@CreatedBy = '',
				@CreatedByOrganization = '',
				@CreatedByNPI = '',
				@UpdatedBy = isnull(PhysicianFirstName + ' ','') + isnull(PhysicianLastName,''),
				@UpdatedByOrganization = FacilityName,
				@UpdatedByNPI = null,
				@UpdatedByContact = PhysicianPhoneName
			from #tempEncounter 
			where ActorID is null

			EXEC Set_CCRActors 
				@CreatedBy = @CreatedBy,
				@CreatedByOrganization = @CreatedByOrganization,
				@CreatedByNPI = @CreatedByNPI,
				@UpdatedBy = @UpdatedBy,
				@UpdatedByOrganization = @UpdatedByOrganization,
				@UpdatedByNPI = @UpdatedByNPI,
				@UpdatedByContact = @UpdatedByContact,
				@ActorID = @tempActorID output,
				@IsValid = @IsValid output

			if(@IsValid = 1 AND len(isnull(@tempActorID,'')) > 0)
			begin
				update #tempEncounter set ActorID = @tempActorID where RecordNumber = @RecordNumber
			end
			else
			begin
				-- Don't include in output
				-- TODO: check if that's desired behavior
				delete from #tempEncounter where RecordNumber = @RecordNumber
			end
		end

		-- get current value of max Object ID
		if exists (select recordnumber from #tempEncounter)
		begin
			select @CurObjID = max(ObjID) from #tempEncounter
		end

		set @EncounterNode = 
		(
			SELECT 
			(
				select  
					ObjID as CCRDataObjectID,
					dbo.Get_CCRFormatDateTime('Encounter Date', VisitDate),
					(	select 'Generic' as [Text]							-- TODO: categorize visits: Office Visit, ER Visit		
						for xml path('Type'),type,elements
					),
					dbo.Get_CCRFormatSource
					(
						ActorID, 
						'Treating clinician' 
					),
					(
						select
						(
							select FacilityName as [Text]
							for xml path('Description'), type, elements
						) 
						for xml path('Location'), type, elements
					) as Locations
				from #tempEncounter
				FOR XML PATH('Encounter'), TYPE, ELEMENTS
			) FOR XML PATH('Encounters'), TYPE, ELEMENTS
		)

		drop table #tempEncounter
	end

END