/****** Object:  Procedure [dbo].[Import_EDVisitHistory]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 4/1/2009
-- Description:	Creates ED Visit record based on imported data
-- =============================================
CREATE PROCEDURE [dbo].[Import_EDVisitHistory]
	@ICENUMBER varchar(15),
	@VisitDate datetime,
	@FacilityName varchar(50),
	@FacilityNPI varchar(50),
	@PhysicianFirstName varchar(50),
	@PhysicianLastName varchar(50),
	@PhysicianPhone varchar(50),
	@Source varchar(50),
	@SourceRecordID int,
	@CancelNotification bit,
	@CancelNotifyReason varchar (100),
	@BillType varchar(20) = null,
	@VisitType varchar(20),
	@FormType varchar(50),
	@POS varchar(50),
	@RevCode varchar(50) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @isHospAdmit bit, @createFlag bit, @existingVisitID varchar(50), @existingVisitSource varchar(50),
		@existingVisitType varchar(50), @VisitDateLo datetime, @VisitDateHi datetime
	SELECT	@VisitDateLo = CONVERT(varchar, @VisitDate, 101), 
			@VisitDateHi = DATEADD(ms, -2, DATEADD(d, 1, @VisitDateLo ))

	set @createFlag = 0

	IF ISNULL(@FacilityName,'') != ''
	begin
		-- Hospital Visit
		-- Delete all physician visits for that date
		--delete from edVisitHistory
		--where icenumber = @icenumber
		--	and (FacilityName is null or FacilityName = '')
		--	and visitdate = @visitDate
	
		IF ISNULL(@FacilityNPI,'') != ''
		begin
			SELECT TOP 1 @existingVisitID = id, 
				@existingVisitSource = source,
				@existingVisitType = visitType
			FROM edvisithistory 
			WHERE icenumber = @icenumber 
				AND visitDate BETWEEN @VisitDateLo AND @VisitDateHi
				AND facilityNPI = @FacilityNPI	
		end
		else 
		begin
			SELECT TOP 1 @existingVisitID = id, 
				@existingVisitSource = source,
				@existingVisitType = visitType
			FROM edvisithistory 
			WHERE icenumber = @icenumber 
				AND visitDate BETWEEN @VisitDateLo AND @VisitDateHi
				AND facilityName = @FacilityName
		end

		IF ISNULL(@existingVisitID,'') = ''
		begin
			set @createFlag = 1
		end
		ELSE IF ISNULL(@existingVisitSource,'') LIKE '%Lookup'
		begin
			-- Set matching flag for existing lookup record
			update edvisithistory
			set MatchName = @Source, MatchRecordID = @SourceRecordID
			where id = @existingVisitID
		end
		ELSE IF @visitType = 'ER' AND ISNULL(@existingVisitSource,'') LIKE '%Claims' AND @existingVisitType != 'ER'
		begin
			update edVisitHistory set Visittype = 'ER', sourceRecordID = @SourceRecordID, source =  @Source
			where ID = @existingVisitID
		end
	end
	ELSE IF NOT EXISTS(SELECT TOP 1 icenumber FROM edvisithistory 
			WHERE icenumber = @icenumber 
				AND visitDate BETWEEN @VisitDateLo AND @VisitDateHi
				and FacilityNPI is not null
				and FacilityNPI = @FacilityNPI)
	begin		
		-- Physician Visit
		-- EMS lookups set visit date and time that's why compare date part only in if statement
		set @createFlag = 1		
	end

	if @createFlag = 1
	begin

		IF ISNULL(@BillType,'') != ''
		begin
			-- Types begining with 11 and 21 mean the patient was admited to the hospital
			-- (Note: before 3/10/2010 it was: Types begining with 11 and 12)
			if(@BillType like '11%' or @BillType like '21%')
			begin
				set @isHospAdmit = 1
			end
			else
			begin
				set @isHospAdmit = 0
			end			
		end		

		-- 10/13/2015 sw - not sure why that would be here Revenue Code and POS (place of service) are different
		--if(ISNULL(@revCode,'') <> '')
		--begin
		--	select @POS = RIGHT(@revCode,3)
		--end

		insert into edvisithistory (
			ICENUMBER
			,VisitDate
			,FacilityName
			,PhysicianFirstName
			,PhysicianLastName
			,PhysicianPhone
			,Source
			,SourceRecordID
			,Created
			,CancelNotification
			,CancelNotifyReason
			,IsHospitalAdmit
			,VisitType
			,FacilityNPI
			,SourceFormType
			,POS
		)
		values(
			@ICENUMBER,
			@VisitDate,
			@FacilityName,
			@PhysicianFirstName,
			@PhysicianLastName,
			@PhysicianPhone,
			@Source,
			@SourceRecordID,
			getutcdate(),
			@CancelNotification,
			@CancelNotifyReason,
			@isHospAdmit,
			@VisitType,
			@FacilityNPI,
			@FormType,
			@POS
		)		
	end
END