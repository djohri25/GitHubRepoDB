/****** Object:  Procedure [dbo].[Set_CCRActors]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 5/7/2009
-- Description:	Based on provided data owner info,
--	return actorID. If actor already exists in Actors 
--	table, return his ID. Otherwise create record in Actors
--	table and return the new record ID.
--	If provided data is not sufficent to identify Actor, 
--	set IsValid flag to 0. Otherwise set it to 1.
-- NOTE: this procedure must be called within the scope of
--	export CCR procedure or within one of the nested calls
--	because this is where #tempActors table is created
-- =============================================
CREATE PROCEDURE [dbo].[Set_CCRActors] 
	@CreatedBy nvarchar(250),
	@CreatedByOrganization varchar(250),
	@CreatedByNPI varchar(20),
	@UpdatedBy nvarchar(250),
	@UpdatedByOrganization varchar(250),
	@UpdatedByNPI varchar(20),
	@UpdatedByContact nvarchar(64),
	@ActorID varchar(6) output,
	@IsValid bit output						-- 0 - invalid data, 1 - valid
AS
BEGIN
	SET NOCOUNT ON;

	declare @patientActorID int				-- ID of actor for whom the CCR is generated

	select @patientActorID = ID from #tempActors where actorRole = 'Patient'

	select @ActorID = '',
		@isValid = 0

	if(len(isnull(@UpdatedBy,'')) = 0 AND len(isnull(@UpdatedByOrganization,'')) = 0)
	begin
		select @UpdatedBy = @CreatedBy,
			@UpdatedByOrganization = @CreatedByOrganization,
			@UpdatedByNPI = @CreatedByNPI
	end

	if(len(isnull(@UpdatedBy,'')) > 0)
	begin
		-- Person
		if(@Updatedby = 'Patient')
		begin
			set @ActorID = @patientActorID
		end
		else if exists (select fullName from #tempActors 
			where len(isnull(@UpdatedByNPI,'')) > 0 
				AND NPI = @UpdatedByNPI)
		begin
			-- Found matching by NPI
			select @ActorID = id from #tempActors where NPI = @UpdatedByNPI
		end
		else if exists (select fullName from #tempActors where fullName = @UpdatedBy)
		begin
			select @ActorID = id from #tempActors where fullName = @UpdatedBy
		end
		else
		begin
			-- Create new Actor record

			select @ActorID = isnull(max(id),0) + 1
			from #tempActors

			insert into #tempActors(
				id, 
				actorType,
				fullName,
				phone,
				NPI
			)
			values(
				@ActorID,
				1,
				@UpdatedBy,
				@UpdatedByContact,
				@UpdatedByNPI
			)
		end

		set @isValid = 1

	end
	else if(len(isnull(@UpdatedByOrganization,'')) > 0)
	begin
		-- Organization
		if exists (select organizationName from #tempActors 
			where len(isnull(@UpdatedByNPI,'')) > 0 
				AND NPI = @UpdatedByNPI)
		begin
			-- Found matching by NPI
			select @ActorID = id from #tempActors where NPI = @UpdatedByNPI
		end
		else if exists (select organizationName from #tempActors where organizationName = @UpdatedByOrganization)
		begin
			select @ActorID = id from #tempActors where organizationName = @UpdatedByOrganization
		end
		else
		begin
			-- Create new Actor record

			select @ActorID = isnull(max(id),0) + 1
			from #tempActors

			insert into #tempActors(
				id, 
				actorType,
				organizationName,
				phone,
				NPI
			)
			values(
				@ActorID,
				2,
				@UpdatedByOrganization,
				@UpdatedByContact,
				@UpdatedByNPI
			)
		end

		set @isValid = 1
	end
	else
	begin
		set @isValid = 0
	end
END