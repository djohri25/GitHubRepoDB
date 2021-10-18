/****** Object:  Procedure [dbo].[Get_CCRProcedures]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 4/24/2009
-- Description:	Get Procedures for specified user
--	formated as XML according to CCR standard
--  If no Procedures exist on record return empty XML
-- NOTE: this procedure must be called within the scope of
--	export CCR procedure or within one of the nested calls
--	because this is where #tempActors table is created
-- =============================================
CREATE procedure [dbo].[Get_CCRProcedures]
(
	@MVDId varchar(20),
	@ProcedureNode xml output,
	@CurObjID int output			-- unique identifier of each object in CCR
)
AS
BEGIN

	DECLARE @coding_version varchar(10),
		@startIdentity int, 
		@IsValid bit			-- 0 - when data owner info invalid, 1 - valid

	select @ProcedureNode = '',
		@coding_version = '2008'	-- TODO: Update if necessary	

	set @startIdentity = @CurObjID + 1

	if exists (select icenumber from mainSurgeries where ICENUMBER = @MVDId)
	begin

		CREATE TABLE #tempProcedure(
			ObjID int IDENTITY(1,1) NOT NULL,
			RecordNumber int,
			Treatment nvarchar(150),
			Code varchar(20),
			CodingSystem varchar(50),
			YearDate datetime,
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
		--DBCC CHECKIDENT (#tempProcedure, reseed, @startIdentity )

		-- DBCC CHECKIDENT requires system admin permissions, use the following instead 
		SET IDENTITY_INSERT #tempProcedure ON
		INSERT INTO #tempProcedure (ObjID) -- This is your primary key field
		VALUES (@startIdentity - 1)
		SET IDENTITY_INSERT #tempProcedure OFF
		DELETE FROM #tempProcedure


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
		insert into #tempProcedure(
			RecordNumber,
			Treatment,
			Code,
			CodingSystem,
			YearDate,
			CreatedBy,
			CreatedByOrganization,
			CreatedByNPI,
			UpdatedBy,
			UpdatedByOrganization,
			UpdatedByNPI,
			UpdatedByContact)
		select RecordNumber,
			Treatment,
			Code,
			CodingSystem,
			YearDate,
			CreatedBy,
			CreatedByOrganization,
			CreatedByNPI,
			UpdatedBy,
			UpdatedByOrganization,
			UpdatedByNPI,
			UpdatedByContact 
		from mainSurgeries
		where ICENUMBER = @MVDId

		-- Assign Actor ID
		-- If same actor already exist in Actors table use his ID.
		-- Otherwise, generate a new ID and insert into actors table.

		while exists (select recordnumber from #tempProcedure where ActorID is null)
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
			from #tempProcedure 
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
				update #tempProcedure set ActorID = @tempActorID where RecordNumber = @RecordNumber
			end
			else
			begin
				-- Don't include in output
				-- TODO: check if that's desired behavior
				delete from #tempProcedure where RecordNumber = @RecordNumber
			end
		end

		-- get current value of max Object ID
		if exists (select recordnumber from #tempProcedure)
		begin
			select @CurObjID = max(ObjID) from #tempProcedure
		end

		set @ProcedureNode = 
		(
			SELECT 
			(
				select  
					ObjID as CCRDataObjectID,
					dbo.Get_CCRFormatDateTime('Procedure Date', YearDate),
					(	select 'Surgery' as [Text]			
						for xml path('Type'),type,elements
					),
					(	
						select  Treatment as [Text],
							CASE ISNULL(Code,'')
							WHEN '' THEN null
							ELSE 
							(
								select Code as [Value], 
									CodingSystem as CodingSystem,
									@coding_version as Version
								for xml path('Code'),type,elements				
							)end			
						for xml path('Description'),type,elements
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
				from #tempProcedure
				FOR XML PATH('Procedure'), TYPE, ELEMENTS
			) FOR XML PATH('Procedures'), TYPE, ELEMENTS
		)

		drop table #tempProcedure
	end

END