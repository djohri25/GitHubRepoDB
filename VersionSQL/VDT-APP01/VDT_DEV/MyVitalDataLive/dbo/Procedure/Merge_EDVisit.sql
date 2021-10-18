/****** Object:  Procedure [dbo].[Merge_EDVisit]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 1/4/2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Merge_EDVisit]
	@MVDID_1 varchar(20),	-- primary MVD record, updated based on record #2
	@MVDID_2 varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	if not exists(select top 1 ID from EDVisitHistory where ICENUMBER = @MVDID_1)
	begin
		insert into EDVisitHistory(
			ICENUMBER,VisitDate,FacilityName,PhysicianFirstName,PhysicianLastName
			,PhysicianPhone,Source,SourceRecordID,Created,CancelNotification
			,CancelNotifyReason,IsHospitalAdmit,VisitType,SourceFormType,MatchName
			,MatchRecordID,FacilityNPI,POS)
		select @MVDID_1,VisitDate,FacilityName,PhysicianFirstName,PhysicianLastName
			,PhysicianPhone,Source,SourceRecordID,Created,CancelNotification
			,CancelNotifyReason,IsHospitalAdmit,VisitType,SourceFormType,MatchName
			,MatchRecordID,FacilityNPI,POS
        from EDVisitHistory
        where ICENUMBER = @MVDID_2
	end
	else
	begin
		declare @recordNumber2 int, @visitDate2 datetime, @facilityName2 varchar(50), @physicianFName2 varchar(50), @physicianLName2 varchar(50),
			@recordNumber1 int
	
		declare @tempEDVisit1 table (
			ID int,ICENUMBER varchar(15),VisitDate datetime,FacilityName nvarchar(50),
			PhysicianFirstName nvarchar(50),PhysicianLastName nvarchar(50),
			PhysicianPhone nvarchar(50),Source nvarchar(50),SourceRecordID int,
			Created datetime,CancelNotification bit,CancelNotifyReason varchar(100),
			IsHospitalAdmit bit,VisitType varchar(50),SourceFormType varchar(50),
			MatchName varchar(50),MatchRecordID int,FacilityNPI varchar(50),POS varchar(50),
			isProcessed bit default(0)
		)

		declare @tempEDVisit2 table (
			ID int,ICENUMBER varchar(15),VisitDate datetime,FacilityName nvarchar(50),
			PhysicianFirstName nvarchar(50),PhysicianLastName nvarchar(50),
			PhysicianPhone nvarchar(50),Source nvarchar(50),SourceRecordID int,
			Created datetime,CancelNotification bit,CancelNotifyReason varchar(100),
			IsHospitalAdmit bit,VisitType varchar(50),SourceFormType varchar(50),
			MatchName varchar(50),MatchRecordID int,FacilityNPI varchar(50),POS varchar(50),
			isProcessed bit default(0)
		)
	
		insert into @tempEDVisit1(
			ID,ICENUMBER,VisitDate,FacilityName,PhysicianFirstName,PhysicianLastName
			,PhysicianPhone,Source,SourceRecordID,Created,CancelNotification
			,CancelNotifyReason,IsHospitalAdmit,VisitType,SourceFormType,MatchName
			,MatchRecordID,FacilityNPI,POS)
		select ID,ICENUMBER,VisitDate,FacilityName,PhysicianFirstName,PhysicianLastName
			,PhysicianPhone,Source,SourceRecordID,Created,CancelNotification
			,CancelNotifyReason,IsHospitalAdmit,VisitType,SourceFormType,MatchName
			,MatchRecordID,FacilityNPI,POS
        from EDVisitHistory
        where ICENUMBER = @MVDID_1

		insert into @tempEDVisit2(
			ID,ICENUMBER,VisitDate,FacilityName,PhysicianFirstName,PhysicianLastName
			,PhysicianPhone,Source,SourceRecordID,Created,CancelNotification
			,CancelNotifyReason,IsHospitalAdmit,VisitType,SourceFormType,MatchName
			,MatchRecordID,FacilityNPI,POS)
		select ID,ICENUMBER,VisitDate,FacilityName,PhysicianFirstName,PhysicianLastName
			,PhysicianPhone,Source,SourceRecordID,Created,CancelNotification
			,CancelNotifyReason,IsHospitalAdmit,VisitType,SourceFormType,MatchName
			,MatchRecordID,FacilityNPI,POS
        from EDVisitHistory
        where ICENUMBER = @MVDID_2
               
        while exists(select top 1 ID from @tempEDVisit2 where isProcessed = 0)
		begin			
			select top 1 
				@recordNumber2 = ID,
				@visitDate2 = VisitDate,
				@facilityName2 = FacilityName,
				@physicianFName2 = PhysicianFirstName,
				@physicianLName2 = PhysicianLastName
			from @tempEDVisit2
			where isProcessed = 0	
	
			select top 1 @recordnumber1 = ID
			from @tempEDVisit1
			where VisitDate = @visitDate2
				AND FacilityName = @facilityName2
				AND PhysicianFirstName = @physicianFName2
				AND PhysicianLastName = @physicianLName2
				
			if ISNULL(@recordNumber1,'') = ''
			begin
			
				insert into EDVisitHistory(
					ICENUMBER
					,VisitDate,FacilityName,PhysicianFirstName,PhysicianLastName
					,PhysicianPhone,Source,SourceRecordID,Created,CancelNotification
					,CancelNotifyReason,IsHospitalAdmit,VisitType,SourceFormType,MatchName
					,MatchRecordID,FacilityNPI,POS)
				select @MVDID_1
					,VisitDate,FacilityName,PhysicianFirstName,PhysicianLastName
					,PhysicianPhone,Source,SourceRecordID,Created,CancelNotification
					,CancelNotifyReason,IsHospitalAdmit,VisitType,SourceFormType,MatchName
					,MatchRecordID,FacilityNPI,POS
				from @tempEDVisit2
				where ID = @recordNumber2
			end
			
			select @recordNumber1 = null
		
			update @tempEDVisit2 set isProcessed = 1
			where ID = @recordNumber2			
		end
	end
END