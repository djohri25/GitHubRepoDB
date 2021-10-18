/****** Object:  Procedure [dbo].[Get_CCRPayers]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 4/24/2009
-- Description:	Get Insurances for specified user
--	formated as XML according to CCR standard
--  If no Insurances exist on record return empty XML
-- NOTE: this procedure must be called within the scope of
--	export CCR procedure or within one of the nested calls
--	because this is where #tempActors table is created
-- =============================================
CREATE procedure [dbo].[Get_CCRPayers]
(
	@MVDId varchar(20),
	@PayerNode xml output,
	@CurObjID int output			-- unique identifier of each object in CCR
)
AS
BEGIN

	DECLARE @startIdentity int, 
		@IsValid bit			-- 0 - when data owner info invalid, 1 - valid

	set @PayerNode = ''

	set @startIdentity = @CurObjID + 1

	if exists (select icenumber from mainInsurance where ICENUMBER = @MVDId)
	begin

		CREATE TABLE #tempInsurance(
			ObjID int IDENTITY(1,1) NOT NULL,
			RecordNumber int,
			Name varchar(50),
			PolicyHolderName varchar(50),
			PolicyNumber varchar(50),
			GroupNumber varchar(50),
			InsuranceType varchar(50),
			address1 varchar(50),
			address2 varchar(50),
			city  varchar(50),
			state  varchar(2),
			zip	 varchar(50),
			Phone varchar(10),
			Fax varchar(50),
			EffectiveDate datetime,
			CreatedBy nvarchar(250),
			CreatedByOrganization varchar(250),
			CreatedByNPI varchar(20),
			UpdatedBy nvarchar(250),
			UpdatedByNPI varchar(20),
			UpdatedByOrganization varchar(250),
			UpdatedByContact nvarchar(64),
			ActorID int,
			PaymentProviderActorID int,
			SubscriberActorID int,
			SubscriberRole varchar(50)
		)

		-- Set identity to start from curObjID + 1
		-- Note: you cannot use variable for seed in create table , 
		-- that's why I have to reseed identity
		-- DBCC CHECKIDENT (#tempInsurance, reseed, @startIdentity )

		-- DBCC CHECKIDENT requires system admin permissions, use the following instead 
		SET IDENTITY_INSERT #tempInsurance ON
		INSERT INTO #tempInsurance (ObjID) -- This is your primary key field
		VALUES (@startIdentity - 1)
		SET IDENTITY_INSERT #tempInsurance OFF
		DELETE FROM #tempInsurance

		declare @RecordNumber int,
			@Name varchar(50),
			@PolicyHolderName varchar(50),
			@address1 varchar(50),
			@address2 varchar(50),
			@city  varchar(50),
			@state  varchar(2),
			@zip	 varchar(50),
			@Phone varchar(10),
			@Fax varchar(50),
			@EffectiveDate datetime,
			@CreatedBy nvarchar(250),
			@CreatedByOrganization varchar(250),
			@CreatedByNPI varchar(20),
			@UpdatedBy nvarchar(250),
			@UpdatedByOrganization varchar(250),
			@UpdatedByNPI varchar(20),
			@UpdatedByContact nvarchar(64),
			@tempActorID varchar(6),
			@PaymentProviderActorID int,
			@PatientActorID int

		select @patientActorID = ID from #tempActors where actorRole = 'Patient'

		-- Temp table is needed to assign Actor/Owner IDs
		insert into #tempInsurance(
			RecordNumber,
			Name,
			PolicyHolderName,
			PolicyNumber,
			GroupNumber,
			InsuranceType,
			address1,
			address2,
			city,
			state,
			zip,
			Phone,
			Fax,
			EffectiveDate,
			CreatedBy,
			CreatedByOrganization,
			CreatedByNPI,
			UpdatedBy,
			UpdatedByOrganization,
			UpdatedByNPI,
			UpdatedByContact)
		select 
			RecordNumber,
			Name,
			PolicyHolderName,
			PolicyNumber,
			GroupNumber,
			(select top 1 InsuranceTypeName + ' Insurance' 
				from LookupInsurancetypeId 
				where InsuranceTypeID = InsuranceTypeID AND InsuranceTypeName <> 'Please Select'),
			address1,
			address2,
			city,
			state,
			postal,
			Phone,
			FaxPhone,
			EffectiveDate,
			CreatedBy,
			CreatedByOrganization,
			CreatedByNPI,
			UpdatedBy,
			UpdatedByOrganization,
			UpdatedByNPI,
			UpdatedByContact 
		from mainInsurance
		where ICENUMBER = @MVDId

		-- Assign Actor ID
		-- If same actor already exist in Actors table use his ID.
		-- Otherwise, generate a new ID and insert into actors table.

		while exists (select recordnumber from #tempInsurance where ActorID is null)
		begin
			-- Reset default value
			set @IsValid = 0

			select top 1 @RecordNumber = RecordNumber,
				@Name = name,
				@PolicyHolderName = PolicyHolderName,
				@address1 = address1,
				@address2 = address2,
				@city = city,
				@state = state,
				@zip = zip,
				@Phone = Phone,
				@Fax = Fax,
				@EffectiveDate = EffectiveDate,
				@CreatedBy = CreatedBy,
				@CreatedByOrganization = CreatedByOrganization,
				@CreatedByNPI = CreatedByNPI,
				@UpdatedBy = UpdatedBy,
				@UpdatedByOrganization = UpdatedByOrganization,
				@UpdatedByNPI = UpdatedByNPI,
				@UpdatedByContact = UpdatedByContact
			from #tempInsurance 
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
				update #tempInsurance set ActorID = @tempActorID where RecordNumber = @RecordNumber

				-- Add (if doesn't exist there yet) insurance company as an actor
				if(len(isnull(@Name,'')) > 0)
				begin
					if exists (select id from #tempActors where organizationName = @name)
					begin
						select @PaymentProviderActorID = id from #tempActors where organizationName = @name
					end
					else
					begin
						select @PaymentProviderActorID = isnull(max(id),0) + 1
						from #tempActors

						insert into #tempActors
						(
							id, 
							actorType,
							organizationName,	
							address1,
							address2,
							city,
							state,
							zip,
							Phone,
							Fax
						)
						values
						(
							@PaymentProviderActorID,
							'2',		-- organization
							@Name,
							@address1,
							@address2,
							@city,
							@state,
							@zip,
							@Phone,
							@Fax
						)
					end

					update #tempInsurance set PaymentProviderActorID = @PaymentProviderActorID where RecordNumber = @RecordNumber
				end

				-- Determine who's the primary subscriber
				if exists (select recordnumber from mainpersonaldetails 
					where icenumber = @mvdId and (isnull(firstName + ' ','') + isnull(lastname,'')) = @PolicyHolderName
					OR len(isnull(@PolicyHolderName,'')) = 0
				)
				begin
					update #tempInsurance set SubscriberActorID = @patientActorID, SubscriberRole = 'Patient'
					where RecordNumber = @RecordNumber
				end
				else
				begin
					declare @tempSubID int

					-- Create new actor
					EXEC Set_CCRActors 
						@CreatedBy = '',
						@CreatedByOrganization = '',
						@CreatedByNPI = '',
						@UpdatedBy = @PolicyHolderName,
						@UpdatedByOrganization = '',
						@UpdatedByNPI = '',
						@UpdatedByContact = '',
						@ActorID = @tempSubID output,
						@IsValid = @IsValid output

					if(@IsValid = 1 AND len(isnull(@tempSubID,'')) > 0)
					begin
						update #tempInsurance set SubscriberActorID = @tempSubID, SubscriberRole = 'Generic'
						where RecordNumber = @RecordNumber
					end
				end
			end
			else
			begin
				-- Don't include in output
				-- TODO: check if that's desired behavior
				delete from #tempInsurance where RecordNumber = @RecordNumber
			end		
		end

		-- get current value of max Object ID
		if exists (select recordnumber from #tempInsurance)
		begin
			select @CurObjID = max(ObjID) from #tempInsurance
		end

		set @PayerNode = 
		(
			SELECT 
			(
				select  
					ObjID as CCRDataObjectID,
					case isnull(EffectiveDate,'')
					when '' then null
					else
					(
						dbo.Get_CCRFormatDateTime('Effective Date', EffectiveDate)
					)END,
					(
						case isnull(PolicyNumber,'')
						when '' then null
						else 
						(
							select	
								'Policy Number' as 'Type/Text',
								PolicyNumber as ID,
								dbo.Get_CCRFormatSource(ActorID, null)
							FOR XML PATH(''), TYPE, ELEMENTS								
						)
						END
					) as IDs,
					(
						select InsuranceType as Text
						FOR XML PATH('Type'), TYPE, ELEMENTS
					),
					dbo.Get_CCRFormatSource(ActorID, 'Data Provider'),
					(
						select PaymentProviderActorID as ActorID
						FOR XML PATH('PaymentProvider'), TYPE, ELEMENTS
					),
					(
						select SubscriberActorID as ActorID,
							(
								select SubscriberRole as Text
								FOR XML PATH('ActorRole'), TYPE, ELEMENTS
							)
						FOR XML PATH('Subscriber'), TYPE, ELEMENTS
					)					
				from #tempInsurance
				FOR XML PATH('Payer'), TYPE, ELEMENTS
			) FOR XML PATH('Payers'), TYPE, ELEMENTS
		)

		drop table #tempInsurance
	end

END