/****** Object:  Procedure [dbo].[Move_ActivatedRecord_FromArchive]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/13/2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Move_ActivatedRecord_FromArchive]
	@mvdid varchar(50)
AS
BEGIN
	SET NOCOUNT ON;	

	DECLARE @TranName VARCHAR(20);
	SELECT @TranName = 'MoveRecord';

	begin transaction @TranName
	
	INSERT INTO UserAdditionalInfo ([MVDID]
           ,[IsPackageSent]
           ,[LastUpdate]
           ,[WasLoggedIn]
           ,[SurveyShowAlways]
           ,[HealthPlanUserNote]
           ,[HealthPlanNoteLastUpdate]) 
	select [MVDID]
           ,[IsPackageSent]
           ,[LastUpdate]
           ,[WasLoggedIn]
           ,[SurveyShowAlways]
           ,[HealthPlanUserNote]
           ,[HealthPlanNoteLastUpdate]
	from MyVitalDataLIVE_Archive.dbo.UserAdditionalInfo
	where MVDID = @mvdid	
	
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
   
	delete from MyVitalDataLIVE_Archive.dbo.UserAdditionalInfo
	where MVDID = @mvdid

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
		
	insert into SectionPermission ([ICENUMBER],[SectionID],[IsPermitted],[CreationDate],[ModifyDate])
	select ICENUMBER,[SectionID],[IsPermitted],[CreationDate],[ModifyDate]
	from MyVitalDataLIVE_Archive.dbo.SectionPermission
	where ICENUMBER = @mvdid

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
	
	delete from MyVitalDataLIVE_Archive.dbo.SectionPermission
	where ICENUMBER = @mvdid

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
	
	insert into MainMedication(ICENUMBER,StartDate,StopDate,RefillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem
       ,RxPharmacy,HowMuch,HowOften,WhyTaking,HVID,CreationDate,ModifyDate,ApproxDate
       ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
       ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,Strength,Route)
	select ICENUMBER,StartDate,StopDate,RefillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem
       ,RxPharmacy,HowMuch,HowOften,WhyTaking,HVID,CreationDate,ModifyDate,ApproxDate
       ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
       ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,Strength,Route
    from MyVitalDataLIVE_Archive.dbo.MainMedication
    where ICENUMBER = @mvdid

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
    
    insert into MainMedicationHistory(ICENUMBER,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,
       CreationDate,ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI)
    select ICENUMBER,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,
       CreationDate,ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI
    from MyVitalDataLIVE_Archive.dbo.MainMedicationHistory
    where ICENUMBER = @mvdid

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
    
    delete from MyVitalDataLIVE_Archive.dbo.MainMedicationHistory
    where ICENUMBER = @mvdid

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
    
    delete from MyVitalDataLIVE_Archive.dbo.MainMedication
    where ICENUMBER = @mvdid

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
			
	insert into MainCondition (ICENUMBER, OtherName, Code, CodingSystem,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact)
	select ICENUMBER, OtherName, Code, CodingSystem,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact
	from MyVitalDataLIVE_Archive.dbo.MainCondition
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END

	delete from MyVitalDataLIVE_Archive.dbo.MainCondition
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
	
	insert into mainSurgeries (ICENUMBER, YearDate, Treatment, Code, CodingSystem, CreationDate,ModifyDate,CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact)
	select ICENUMBER, YearDate, Treatment, Code, CodingSystem, CreationDate,ModifyDate,CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact
	from MyVitalDataLIVE_Archive.dbo.MainSurgeries
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END

	delete from MyVitalDataLIVE_Archive.dbo.MainSurgeries
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
		
	insert into MainSurgeriesHistoryLive.dbo.MainSurgeriesHistory(ICENUMBER,YearDate,Treatment,Code,CodingSystem,CreationDate,CreatedBy
		,CreatedByOrganization,CreatedByNPI,CreatedByContact,ImportRecordID)
	select ICENUMBER,YearDate,Treatment,Code,CodingSystem,CreationDate,CreatedBy
		,CreatedByOrganization,CreatedByNPI,CreatedByContact,ImportRecordID
	from MyVitalDataLIVE_Archive.dbo.MainSurgeriesHistory
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END

	delete from MyVitalDataLIVE_Archive.dbo.MainSurgeriesHistory
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
		
	INSERT INTO MainPlaces(	ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,FaxPhone,WebSite,PlacesTypeID,
		RoomLoc,Direction,Note,CreationDate,ModifyDate)	
	select 	ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,FaxPhone,WebSite,PlacesTypeID,
		RoomLoc,Direction,Note,CreationDate,ModifyDate
	from MyVitalDataLIVE_Archive.dbo.MainPlaces	
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END

	delete from MyVitalDataLIVE_Archive.dbo.MainPlaces	
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
	
	insert into edvisithistory (ICENUMBER,VisitDate,FacilityName,PhysicianFirstName,PhysicianLastName,PhysicianPhone
			,Source,SourceRecordID,Created,CancelNotification,CancelNotifyReason,IsHospitalAdmit,VisitType
			,FacilityNPI,SourceFormType,POS)	
	select ICENUMBER,VisitDate,FacilityName,PhysicianFirstName,PhysicianLastName,PhysicianPhone
			,Source,SourceRecordID,Created,CancelNotification,CancelNotifyReason,IsHospitalAdmit,VisitType
			,FacilityNPI,SourceFormType,POS
	from MyVitalDataLIVE_Archive.dbo.EDVisitHistory
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END

	delete from MyVitalDataLIVE_Archive.dbo.EDVisitHistory
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END	      

	delete from MyVitalDataLIVE_Archive.dbo.Link_MemberId_MVD_Ins
	where MVDId = @mvdid  
	
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
	
		-- Set Record as already processed
	update Link_MemberId_MVD_Ins
	set isArchived = 0, ArchivedDate = null, ArchiveAttemptCount = 0
	where MVDId = @MVDId
	
	commit transaction @TranName			 
END