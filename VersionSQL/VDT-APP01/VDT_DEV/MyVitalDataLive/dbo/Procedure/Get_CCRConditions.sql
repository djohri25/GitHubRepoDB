/****** Object:  Procedure [dbo].[Get_CCRConditions]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 4/24/2009
-- Description:	Get Conditions/Problems for specified user
--	formated as XML according to CCR standard.
--  If no conditions exist on record return empty XML
-- NOTE: this procedure must be called within the scope of
--	export CCR procedure or within one of the nested calls
--	because this is where #tempActors table is created
-- =============================================
CREATE procedure [dbo].[Get_CCRConditions]
(
	@MVDId varchar(20),
	@ConditionNode xml output,
	@CurObjID int output			-- unique identifier of each object in CCR
)
AS
BEGIN

	DECLARE @ICD9_version varchar(10), 
		@startIdentity int, 
		@IsValid bit			-- 0 - when data owner info invalid, 1 - valid

	set @ConditionNode = ''
	
	set @ICD9_version = '2008'	-- TODO: Update if necessary	

	set @startIdentity = @CurObjID + 1

	if exists (select icenumber from maincondition where ICENUMBER = @MVDId)
	begin

		CREATE TABLE #tempCondition(
			ObjID int IDENTITY(1,1) NOT NULL,
			RecordNumber int,
			ConditionId int,
			OtherName nvarchar(50),
			Code varchar(20),
			CodingSystem varchar(50),
			ReportDate datetime,
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
		-- DBCC CHECKIDENT (#tempCondition, reseed, @startIdentity )

		-- DBCC CHECKIDENT requires system admin permissions, use the following instead 
		SET IDENTITY_INSERT #tempCondition ON
		INSERT INTO #tempCondition (ObjID) -- This is your primary key field
		VALUES (@startIdentity - 1)
		SET IDENTITY_INSERT #tempCondition OFF
		DELETE FROM #tempCondition

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
		insert into #tempCondition(
			RecordNumber,
			ConditionId,
			OtherName,
			Code,
			CodingSystem,
			ReportDate,
			CreatedBy,
			CreatedByOrganization,
			CreatedByNPI,
			UpdatedBy,
			UpdatedByOrganization,
			UpdatedByNPI,
			UpdatedByContact)
		select RecordNumber,
			ConditionId,
			OtherName,
			Code,
			CodingSystem,
			ReportDate,
			CreatedBy,
			CreatedByOrganization,
			CreatedByNPI,
			UpdatedBy,
			UpdatedByOrganization,
			UpdatedByNPI,
			UpdatedByContact 
		from maincondition 
		where ICENUMBER = @MVDId

		-- Assign Actor ID
		-- If same actor already exist in Actors table use his ID.
		-- Otherwise, generate a new ID and insert into actors table.

		while exists (select recordnumber from #tempCondition where ActorID is null)
		begin
			-- Reset default value
			set @IsValid = 0

			select top 1 @RecordNumber = RecordNumber,
				@CreatedBy = CreatedBy,
				@CreatedByOrganization = CreatedByOrganization,
				@CreatedByNPI = CreatedByNPI,
				@UpdatedBy = UpdatedBy,
				@UpdatedByOrganization = UpdatedByOrganization,
				@UpdatedByNPI = UpdatedByNPI,
				@UpdatedByContact = UpdatedByContact
			from #tempCondition 
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
				update #tempCondition set ActorID = @tempActorID where RecordNumber = @RecordNumber
			end
			else
			begin
				-- Don't include in output
				-- TODO: check if that's desired behavior
				delete from #tempCondition where RecordNumber = @RecordNumber
			end
		end

		-- get current value of max Object ID
		if exists (select recordnumber from #tempCondition)
		begin
			select @CurObjID = max(ObjID) from #tempCondition
		end

		set @ConditionNode = 
		(
			SELECT 
			(
				select 
					ObjID as CCRDataObjectID,
					dbo.Get_CCRFormatDateTime('Start date', ReportDate),
					(	select 'Diagnosis' as [Text]			
						for xml path('Type'),type,elements
					),
					(
						case isnull(ConditionID,'')
						when  '' then 
						(
							case isnull(code,'')
							when '' then
							(
								select OtherName as [Text]			
								for xml path(''),type,elements
							)
							else
							( 
								select OtherName as Text,
									(
										select Code as [Value],
											CodingSystem,
											@ICD9_version as Version
										for xml path('Code'),type,elements
									)
								for xml path(''),type,elements
							)
							end
						)
						else
						(
							-- MVD Condition lookup value set
							select ConditionName as Text 
							from lookupCondition
							where ConditionId = mc.ConditionID
							FOR XML PATH(''), TYPE, ELEMENTS
						)
						end

					) as Description,
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
										else 'Treating clinician' 
									end
								)
								else
								(
									'Treating facility' 
								)end

							from #tempActors where ID = ActorID
						)
					)

				from #tempCondition mc
				FOR XML PATH('Problem'), TYPE, ELEMENTS
			) FOR XML PATH('Problems'), TYPE, ELEMENTS
		)

		drop table #tempCondition
	end

END