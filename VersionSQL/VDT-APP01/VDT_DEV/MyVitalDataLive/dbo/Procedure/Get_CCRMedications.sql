/****** Object:  Procedure [dbo].[Get_CCRMedications]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 4/24/2009
-- Description:	Get Medications for specified user
--	formated as XML according to CCR standard
--  If no Medications exist on record return empty XML
-- =============================================
CREATE procedure [dbo].[Get_CCRMedications]
(
	@MVDId varchar(20),
	@MedicationNode xml output,
	@CurObjID int output			-- unique identifier of each object in CCR
)
AS
BEGIN

	DECLARE @startIdentity int, 
		@startHistoryIdentity int,
		@IsValid bit			-- 0 - when data owner info invalid, 1 - valid

	set @startIdentity = @CurObjID + 1

	if exists (select icenumber from mainmedication where ICENUMBER = @MVDId)
	begin

		CREATE TABLE #tempMedication(
			ObjID int IDENTITY(1,1) NOT NULL,
			RecordNumber int,
			StartDate datetime,
			RefillDate datetime,
			rxdrug nvarchar(100),
			Code varchar(20),
			CodingSystem varchar(50),
			CreatedBy nvarchar(250),
			CreatedByOrganization varchar(250),
			CreatedByNPI varchar(20),
			UpdatedBy nvarchar(250),
			UpdatedByNPI varchar(20),
			UpdatedByOrganization varchar(250),
			UpdatedByContact nvarchar(64),
			ActorID int
		)

		-- Set identity to start from curObjID + 1
		-- Note: you cannot use variable for seed in create table , 
		-- that's why I have to reseed identity
		-- DBCC CHECKIDENT (#tempMedication, reseed, @startIdentity )

		-- DBCC CHECKIDENT requires system admin permissions, use the following instead 
		SET IDENTITY_INSERT #tempMedication ON
		INSERT INTO #tempMedication (ObjID) -- This is your primary key field
		VALUES (@startIdentity - 1)
		SET IDENTITY_INSERT #tempMedication OFF
		DELETE FROM #tempMedication

		CREATE TABLE #tempMedicationHistory(
			ObjID int IDENTITY(1,1) NOT NULL,
			RecordNumber int,
			FillDate datetime,
			rxdrug nvarchar(100),
			Code varchar(20),
			CodingSystem varchar(50),
			CreatedBy nvarchar(250),
			CreatedByOrganization varchar(250),
			CreatedByNPI varchar(20),
			CreatedByContact nvarchar(64),
			ActorID int
		)

		declare @RecordNumber int,
			@RefillDate datetime,
			@Rxdrug nvarchar(100),
			@CreatedBy nvarchar(250),
			@CreatedByOrganization varchar(250),
			@CreatedByNPI varchar(20),
			@UpdatedBy nvarchar(250),
			@UpdatedByOrganization varchar(250),
			@UpdatedByNPI varchar(20),
			@UpdatedByContact nvarchar(64),
			@tempActorID varchar(6)

		-- Temp table is needed to assign Actor/Owner IDs
		insert into #tempMedication(
			RecordNumber,
			StartDate,
			RefillDate,
			rxdrug,
			Code,
			CodingSystem,
			CreatedBy,
			CreatedByOrganization,
			CreatedByNPI,
			UpdatedBy,
			UpdatedByOrganization,
			UpdatedByNPI,
			UpdatedByContact)
		select RecordNumber,
			startdate,
			refilldate,
			rxdrug,
			Code,
			CodingSystem,
			CreatedBy,
			CreatedByOrganization,
			CreatedByNPI,
			UpdatedBy,
			UpdatedByOrganization,
			UpdatedByNPI,
			UpdatedByContact 
		from mainmedication 
		where ICENUMBER = @MVDId

		-- Set identity to start from "max med id + 1"
		select @startHistoryIdentity = max(ObjID) + 1
		from #tempMedication

--		DBCC CHECKIDENT (#tempMedicationHistory, reseed, @startHistoryIdentity )


		SET IDENTITY_INSERT #tempMedicationHistory ON
		INSERT INTO #tempMedicationHistory (ObjID) -- This is your primary key field
		VALUES (@startHistoryIdentity - 1)
		SET IDENTITY_INSERT #tempMedicationHistory OFF
		DELETE FROM #tempMedicationHistory

		-- Assign Actor ID and set History
		-- If same actor already exist in Actors table use his ID.
		-- Otherwise, generate a new ID and insert into actors table.

		while exists (select recordnumber from #tempMedication where ActorID is null)
		begin
			-- Reset default value
			set @IsValid = 0

			select top 1 @RecordNumber = RecordNumber,
				@RefillDate = RefillDate,
				@Rxdrug = Rxdrug,
				@CreatedBy = CreatedBy,
				@CreatedByOrganization = CreatedByOrganization,
				@CreatedByNPI = CreatedByNPI,
				@UpdatedBy = UpdatedBy,
				@UpdatedByOrganization = UpdatedByOrganization,
				@UpdatedByNPI = UpdatedByNPI,
				@UpdatedByContact = UpdatedByContact
			from #tempMedication 
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
				update #tempMedication set ActorID = @tempActorID where RecordNumber = @RecordNumber

				-- Create refill history
				insert into #tempMedicationHistory(
					RecordNumber,
					FillDate,
					rxdrug,
					Code,
					CodingSystem,
					CreatedBy,
					CreatedByOrganization,
					CreatedByNPI,
					CreatedByContact)
				select 
					RecordNumber,
					FillDate,
					rxdrug,
					Code,
					CodingSystem,
					CreatedBy,
					CreatedByOrganization,
					CreatedByNPI,
					CreatedByContact
				from MainMedicationHistory mh
				where mh.IceNumber = @MVDId and mh.RxDrug = @Rxdrug
					-- Skip records for which Refill date wasn't set
					-- (e.g. when the med record is first time created, refill date is not set but
					-- history record is created in MedHistory table)
					AND len(CASE ISNULL(@RefillDate,'')
							WHEN '' THEN ''
							ELSE ('DUMMY')
						END) > 0
					AND mh.RecordNumber not in (
						-- Exclude one record, the most recent history record which already updated
						-- the main med record
						select top 1 RecordNumber from MainMedicationHistory mh2
						where mh2.Icenumber = @MVDId 
							and mh2.RxDrug = @Rxdrug
							and mh2.FillDate = isnull(@RefillDate,'')
					)
			end
			else
			begin
				-- Don't include in output
				-- TODO: check if that's desired behavior
				delete from #tempMedication where RecordNumber = @RecordNumber
			end
		end

		-- Assign Actor ID to Med History records
		-- If same actor already exist in Actors table use his ID.
		-- Otherwise, generate a new ID and insert into actors table.
		while exists (select recordnumber from #tempMedicationHistory where ActorID is null)
		begin
			-- Reset default value
			set @IsValid = 0

			select top 1 @RecordNumber = RecordNumber,
				@CreatedBy = CreatedBy,
				@CreatedByOrganization = CreatedByOrganization,
				@CreatedByNPI = CreatedByNPI,
				@UpdatedByContact = CreatedByContact
			from #tempMedicationHistory 
			where ActorID is null

			EXEC Set_CCRActors 
				@CreatedBy = @CreatedBy,
				@CreatedByOrganization = @CreatedByOrganization,
				@CreatedByNPI = @CreatedByNPI,
				@UpdatedBy = '',
				@UpdatedByOrganization = '',
				@UpdatedByNPI = '',
				@UpdatedByContact = @UpdatedByContact,
				@ActorID = @tempActorID output,
				@IsValid = @IsValid output

			if(@IsValid = 1 AND len(isnull(@tempActorID,'')) > 0)
			begin
				update #tempMedicationHistory set ActorID = @tempActorID where RecordNumber = @RecordNumber
			end
			else
			begin
				-- Don't include in output
				-- TODO: check if that's desired behavior
				delete from #tempMedicationHistory where RecordNumber = @RecordNumber
			end
		end

		-- get current value of max Object ID
		if exists ( select recordnumber from #tempMedicationHistory)
		begin
			-- Med History table used obj id last			
			select @CurObjID = max(ObjID) from #tempMedicationHistory
		end
		else if exists (select recordnumber from #tempMedication)
		begin
			select @CurObjID = max(ObjID) from #tempMedication
		end

		set @MedicationNode = 
		(
			SELECT 
			(				
				select  
					ObjID as CCRDataObjectID,
					dbo.Get_CCRFormatDateTime('Start Date', startdate),
					(	select 'Medication' as [Text]			
						for xml path('Type'),type,elements
					),
					dbo.Get_CCRFormatSource
					(
						ActorID, 
						(
							select 
								case convert(varchar,ActorType,5)
								when '1' then
								(
									case UpdatedBy 
										when 'patient' then 'Self' 
										else 'Prescribing clinician'
									end
								)
								else
								(
									'Prescribing facility' 
								)end

							from #tempActors where ID = ActorID
						)
					),
					--===================== PRODUCT =====================
					(	select (select rxdrug as [Text],
							CASE ISNULL(Code,'')
							WHEN '' THEN null
							ELSE 
							(
								select Code as [Value], CodingSystem as CodingSystem
								for xml path('Code'),type,elements				
							)end
							for xml path('ProductName'),type,elements
						) 
						for xml path('Product'),type,elements
					),

					--===================== FULFILLMENT HISTORY ==========
					isnull((	
						SELECT 
							mh.ObjID as CCRDataObjectID,
							dbo.Get_CCRFormatDateTime('Dispense date', 
								CASE ISNULL(FillDate,'')
								WHEN '' THEN ''
								ELSE 
								(
									CONVERT(VARCHAR(30),ISNULL(FILLDATE,''),101)
								)
								END
							),
							dbo.Get_CCRFormatSource
							(
								ActorID, 
								(
									select 
										case convert(varchar,ActorType,5)
										when '1' then
										(
											case UpdatedBy 
												when 'patient' then 'Self' 
												else 'Prescribing clinician'
											end
										)
										else
										(
											'Prescribing facility' 
										)end

									from #tempActors where ID = ActorID
								)
							)
						from #tempMedicationHistory mh
						where mh.RxDrug = b.Rxdrug
					  FOR XML PATH('Fulfillment'),TYPE, ELEMENTS
					),'') AS FulfillmentHistory
				from #tempMedication b
				FOR XML PATH('Medication'), TYPE, ELEMENTS
			) FOR XML PATH('Medications'), TYPE, ELEMENTS
		)

		drop table #tempMedication
	end


END