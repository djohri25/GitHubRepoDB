/****** Object:  Procedure [dbo].[Set_EDVisitHistory]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 8/4/2008
-- Description:	Inserts EDVisitHistory record
-- =============================================
CREATE PROCEDURE [dbo].[Set_EDVisitHistory]
	@ICENUMBER varchar(15)
	  ,@VisitDate datetime
      ,@FacilityName varchar(50)
      ,@PhysicianFirstName varchar(50)
      ,@PhysicianLastName varchar(50)
      ,@PhysicianPhone varchar(50)
      ,@Source varchar(50)
      ,@SourceRecordID int
	  ,@AccessReason varchar(2000),
	  @OriginalVisitType varchar(50) = null
as
	  
	declare @CancelNotification bit, @CancelNotifyReason varchar(100)
	declare @IDoc int				-- handle to XML
	declare @visitType varchar(50), @facilityNPI varchar(50), @createFlag bit, @ChiefComplaint varchar(100)
	declare @ID	int

	IF LEFT(@AccessReason,1) = '<' AND RIGHT(@AccessReason,1) = '>'
	BEGIN
		-- Check if the record access notification was canceled and why
		-- These record won't be displayed on ED Visit history seen by the record owner
		-- Note: other applications using MVD API don't have to format AccessReason in XML
		BEGIN TRY
			EXEC sp_xml_preparedocument @IDoc OUTPUT, @AccessReason

			SELECT @CancelNotification = CANCELNOTIFICATION
			FROM OPENXML (@IDoc, 'ACCESSREASON', 2)
			with (CANCELNOTIFICATION bit)

			SELECT @CancelNotifyReason = CANCELNOTIFYREASON
			FROM OPENXML (@IDoc, 'ACCESSREASON', 2)
			with (CANCELNOTIFYREASON varchar(100))

			if( @CancelNotification is null)
			begin
				set @CancelNotification = 0
			end

			EXEC sp_xml_removedocument @IDoc
		END TRY
		BEGIN CATCH		
			select @CancelNotification = 0, @CancelNotifyReason = ''
		END CATCH
	END
	ELSE
	BEGIN
		select @CancelNotification = 0, @CancelNotifyReason = ''
	END

	if(@Source = 'EMS - Lookup')	
	begin
		set @visitType = 'ER'			-- Currently all MVD assiciated Hospital Lookups are considered ER (9/16/2009)
		
		select @facilityNPI = NPI
		from mvd_apprecord a
			inner join mainEmsHospital h on a.UserFacilityID = h.ID
		where a.RecordID = @sourceRecordID
	end
	else if(@Source = 'Discharge Data')
	begin
		if(@OriginalVisitType is not null)
		begin
			if(@OriginalVisitType like '%Emergency%')
			begin
				set @visitType = 'ER'
			end
			else
			begin
				set @visitType = 'OTHER'
			end
		end
		else
		begin
			set @visitType = 'ER'
		end
		
		EXEC Get_FacilityNPI
			@FacilityName = @facilityName,
			@visitSourceName = @Source,
			@NPI = @facilityNPI output

		--select @facilityNPI = NPI
		--from mainEmsHospital
		--where Name = @FacilityName
		
		select @ChiefComplaint = @AccessReason
	end
	else
	begin
		set @visitType = 'OTHER'
	end

	set @createFlag = 1

	-- Check if same visit already exists
	if(isnull(@FacilityName,'') <> '' and isnull(@FacilityNPI,'') <> '' and
		exists(
			select top 1 ID from EDVisitHistory vh
			where icenumber = @ICENUMBER
				and convert(varchar(10),visitDate,101) = convert(varchar(10),@VisitDate,101)
				and
				( 
					facilityNPI = @FacilityNPI
					OR
					exists (
						-- check if both NPIs don't belong to the same main facility NPI
						select top 1 * 
						from DischargeReportFacility a
							cross join DischargeReportFacility b
						where a.AssociatedNPI = vh.FacilityNPI and b.AssociatedNPI = @FacilityNPI and a.MainNPI = b.MainNPI
					)
				--and facilityName = @FacilityName
				)
		)
	)
	begin
		set @createFlag = 0
	end		
	else if len(isnull(@FacilityName,'')) = 0 and exists(
		select top 1 ID from EDVisitHistory
		where icenumber = @ICENUMBER
			and convert(varchar(10),visitDate,101) = convert(varchar(10),@VisitDate,101)
			and PhysicianLastName = @PhysicianLastName
			and PhysicianFirstName = @PhysicianFirstName
	)
	begin
		set @createFlag = 0
	end

	if(@createFlag = 1)
	begin
		insert into EDVisitHistory
		   (ICENUMBER
		  ,VisitDate
		  ,FacilityName
		  ,PhysicianFirstName
		  ,PhysicianLastName
		  ,PhysicianPhone
		  ,Source
		  ,SourceRecordID
		  ,CancelNotification
		  ,CancelNotifyReason
		  ,VisitType
		  ,FacilityNPI
		  ,ChiefComplaint)
		values(
		   @ICENUMBER
		  ,@VisitDate
		  ,@FacilityName
		  ,@PhysicianFirstName
		  ,@PhysicianLastName
		  ,@PhysicianPhone
		  ,@Source
		  ,@SourceRecordID
		  ,@CancelNotification
		  ,@CancelNotifyReason
		  ,@VisitType
		  ,@FacilityNPI
		  ,@ChiefComplaint
		)
		SET @ID = SCOPE_IDENTITY();

		UPDATE  EDVisitHistory
		SET SourceFormType = 'HRMC'
		WHERE ID = @ID and ICENUMBER = @ICENUMBER and VisitDate = @VisitDate and FacilityName = 'Hunt Regional Medical Center'
	end