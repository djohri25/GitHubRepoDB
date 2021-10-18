/****** Object:  Procedure [dbo].[Move_InactiveMemberRecord]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Move_InactiveMemberRecord]
	@mvdid varchar(50)
AS
BEGIN
	SET NOCOUNT ON;	

	DECLARE @TranName VARCHAR(20);
	SELECT @TranName = 'MoveRecord';

	begin transaction @TranName
	
	INSERT INTO MyVitalDataLIVE_Archive.dbo.UserAdditionalInfo ([MVDID]
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
	from UserAdditionalInfo
	where MVDID = @mvdid	
	
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
   
	delete from UserAdditionalInfo
	where MVDID = @mvdid

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
		
	insert into MyVitalDataLIVE_Archive.dbo.SectionPermission ([ICENUMBER],[SectionID],[IsPermitted],[CreationDate],[ModifyDate])
	select ICENUMBER,[SectionID],[IsPermitted],[CreationDate],[ModifyDate]
	from SectionPermission
	where ICENUMBER = @mvdid

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
	
	delete from SectionPermission
	where ICENUMBER = @mvdid

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
	
	insert into MyVitalDataLIVE_Archive.dbo.MainMedication(ICENUMBER,StartDate,StopDate,RefillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem
       ,RxPharmacy,HowMuch,HowOften,WhyTaking,HVID,CreationDate,ModifyDate,ApproxDate
       ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
       ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,Strength,Route)
	select ICENUMBER,StartDate,StopDate,RefillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem
       ,RxPharmacy,HowMuch,HowOften,WhyTaking,HVID,CreationDate,ModifyDate,ApproxDate
       ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
       ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,Strength,Route
    from MainMedication
    where ICENUMBER = @mvdid

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
    
    insert into MyVitalDataLIVE_Archive.dbo.MainMedicationHistory(ICENUMBER,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,
       CreationDate,ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI)
    select ICENUMBER,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,
       CreationDate,ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI
    from MainMedicationHistory
    where ICENUMBER = @mvdid

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
    
    delete from MainMedicationHistory
    where ICENUMBER = @mvdid

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
    
    delete from MainMedication
    where ICENUMBER = @mvdid

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
		
	--insert into MyVitalDataLIVE_Archive.dbo.MainCareInfo (ICENUMBER, LastName, FirstName, Address1, Address2,
	--		City, State, Postal, PhoneHome, PhoneCell, PhoneOther, CareTypeId, 
	--		RelationshipId, CreationDate, ModifyDate,ContactType, EmailAddress, NotifyByEmail, 
	--		NotifyBySMS,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact) 
	--select ICENUMBER, LastName, FirstName, Address1, Address2,
	--		City, State, Postal, PhoneHome, PhoneCell, PhoneOther, CareTypeId, 
	--		RelationshipId, CreationDate, ModifyDate,ContactType, EmailAddress, NotifyByEmail, 
	--		NotifyBySMS,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact
	--from MainCareInfo
	--where ICENUMBER = @mvdid

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
	
	--delete from MainCareInfo
	--where ICENUMBER = @mvdid

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
	
	--insert into MyVitalDataLIVE_Archive.dbo.MainInsurance (ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,
	--		PolicyHolderName,PolicyNumber,InsuranceTypeID,EffectiveDate,TerminationDate,
	--		MedicareNumber,Medicaid,CHIP_ID,
	--		CreationDate,ModifyDate,
	--		CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact)
	--select ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,
	--		PolicyHolderName,PolicyNumber,InsuranceTypeID,EffectiveDate,TerminationDate,
	--		MedicareNumber,Medicaid,CHIP_ID,
	--		CreationDate,ModifyDate,
	--		CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact
	--from MainInsurance
	--where ICENUMBER = @mvdid	

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
	
	--delete from MainInsurance
	--where ICENUMBER = @mvdid	

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
	
	--insert into MyVitalDataLIVE_Archive.dbo.MainSpecialist([ICENUMBER],[LastName],[FirstName],[Address1],[Address2],[City],	
	--			[State],[Postal],[Phone],[RoleID],[CreationDate],[ModifyDate],[NPI])
	--select ICENUMBER,[LastName],[FirstName],[Address1],[Address2],[City],	
	--			[State],[Postal],[Phone],[RoleID],[CreationDate],[ModifyDate],[NPI]
	--from MainSpecialist
	--where ICENUMBER = @mvdid	

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
	
	--delete from MainSpecialist
	--where ICENUMBER = @mvdid	

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
	
	insert into MyVitalDataLIVE_Archive.dbo.MainCondition (ICENUMBER, OtherName, Code, CodingSystem,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact,
		RevCode,BillType,POS,DRGCode,DischargeStatus,AdmissionDate,DischargeDate,IsPrincipal)
	select ICENUMBER, OtherName, Code, CodingSystem,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact,
		RevCode,BillType,POS,DRGCode,DischargeStatus,AdmissionDate,DischargeDate,IsPrincipal
	from MainCondition
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END

	delete from MainCondition
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
	
	insert into MyVitalDataLIVE_Archive.dbo.mainSurgeries (ICENUMBER, YearDate, Treatment, Code, CodingSystem, CreationDate,ModifyDate,CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact,
		RevCode,BillType,POS,DRGCode,DischargeStatus,AdmissionDate,DischargeDate)
	select ICENUMBER, YearDate, Treatment, Code, CodingSystem, CreationDate,ModifyDate,CreatedBy,CreatedByOrganization,CreatedByNPI,UpdatedBy,UpdatedByOrganization,UpdatedByNPI,UpdatedByContact,
		RevCode,BillType,POS,DRGCode,DischargeStatus,AdmissionDate,DischargeDate
	from MainSurgeries
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END

	delete from MainSurgeries
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
		
			
	INSERT INTO MyVitalDataLIVE_Archive.dbo.MainPlaces(	ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,FaxPhone,WebSite,PlacesTypeID,
		RoomLoc,Direction,Note,CreationDate,ModifyDate)	
	select 	ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,FaxPhone,WebSite,PlacesTypeID,
		RoomLoc,Direction,Note,CreationDate,ModifyDate
	from MainPlaces	
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END

	delete from MainPlaces	
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
	
	insert into MyVitalDataLIVE_Archive.dbo.edvisithistory (ICENUMBER,VisitDate,FacilityName,PhysicianFirstName,PhysicianLastName,PhysicianPhone
			,Source,SourceRecordID,Created,CancelNotification,CancelNotifyReason,IsHospitalAdmit,VisitType
			,FacilityNPI,SourceFormType,POS)	
	select ICENUMBER,VisitDate,FacilityName,PhysicianFirstName,PhysicianLastName,PhysicianPhone
			,Source,SourceRecordID,Created,CancelNotification,CancelNotifyReason,IsHospitalAdmit,VisitType
			,FacilityNPI,SourceFormType,POS
	from EDVisitHistory
	where  ICENUMBER = @mvdid --and VisitDate < '1/1/2010'			

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END

	delete from EDVisitHistory
	where  ICENUMBER = @mvdid	

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
	
	--INSERT INTO MyVitalDataLIVE_Archive.[dbo].[MainDiseaseManagement]
 --          ([ICENUMBER],[Created],[DM_ID],[name])
	--select [ICENUMBER],[Created],[DM_ID],[name]
	--from MainDiseaseManagement
	--where  ICENUMBER = @mvdid	

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
	
	--delete from MainDiseaseManagement
	--where  ICENUMBER = @mvdid	

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
	
	--insert into MyVitalDataLIVE_Archive.dbo.MainLabRequest(ICENUMBER,OrderID,OrderName,OrderCode,OrderCodingSystem
	--	,RequestDate,OrderingPhysicianFirstName,OrderingPhysicianLastName
	--	,OrderingPhysicianID,ProcedureName,ProcedureCode,ProcedureCodingSystem
	--	,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
	--	,UpdatedByContact,CreatedByNPI,UpdatedByNPI,SourceName)
	--select ICENUMBER,OrderID,OrderName,OrderCode,OrderCodingSystem
	--	,RequestDate,OrderingPhysicianFirstName,OrderingPhysicianLastName
	--	,OrderingPhysicianID,ProcedureName,ProcedureCode,ProcedureCodingSystem
	--	,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
	--	,UpdatedByContact,CreatedByNPI,UpdatedByNPI,SourceName
 --   from MainLabRequest
 --   where ICENUMBER = @mvdid

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
    
	--insert into MyVitalDataLIVE_Archive.dbo.MainLabResult(ICENUMBER,OrderID,ResultID,ResultName,Code
	--	,CodingSystem,ResultValue,ResultUnits,RangeLow,RangeHigh,RangeAlpha
	--	,AbnormalFlag,ReportedDate,Notes,CreationDate,CreatedBy,CreatedByOrganization
	--	,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI
	--	,UpdatedByNPI,SourceName)
	--select ICENUMBER,OrderID,ResultID,ResultName,Code,CodingSystem,ResultValue
	--	,ResultUnits,RangeLow,RangeHigh,RangeAlpha,AbnormalFlag,ReportedDate
	--	,Notes,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy
	--	,UpdatedByOrganization,UpdatedByContact,CreatedByNPI
	--	,UpdatedByNPI,SourceName
 --   from MainLabResult
 --   where ICENUMBER = @mvdid

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
    
	--insert into MyVitalDataLIVE_Archive.dbo.MainLabNote(ICENUMBER,ResultID,Note,CreationDate,CreatedBy
	--	,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact
	--	,CreatedByNPI,UpdatedByNPI,SourceName,SequenceNum)
	--select ICENUMBER,ResultID,Note,CreationDate,CreatedBy
	--	,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact
	--	,CreatedByNPI,UpdatedByNPI,SourceName,SequenceNum
 --   from MainLabNote
 --   where ICENUMBER = @mvdid                

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
	
	--delete from MainLabNote
 --   where ICENUMBER = @mvdid  

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
    
 --   delete from MainLabResult
 --   where ICENUMBER = @mvdid

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
    
 --   delete from MainLabRequest
 --   where ICENUMBER = @mvdid

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
	
	--insert into MyVitalDataLIVE_Archive.dbo.MainPersonalDetails ([ICENUMBER],[LastName],[FirstName],[GenderID],[SSN],[DOB],[Address1],[Address2]
 --          ,[City],[State],[PostalCode],[HomePhone],[CellPhone],[WorkPhone],[FaxPhone],[Email],[BloodTypeID]
 --          ,[OrganDonor],[HeightInches],[WeightLbs],[MaritalStatusID],[EconomicStatusID],[Occupation],[Hours]
 --          ,[CreationDate],[ModifyDate],[MaxAttachmentLimit],[CreatedBy],[CreatedByOrganization],[UpdatedBy]
 --          ,[UpdatedByOrganization],[UpdatedByContact],[Organization],[Language],[Ethnicity],[CreatedByNPI]
 --          ,[UpdatedByNPI],[InCaseManagement],[NarcoticLockdown],[MiddleName])
 --  select ICENUMBER,[LastName],[FirstName],[GenderID],[SSN],[DOB],[Address1],[Address2]
	--	   ,[City],[State],[PostalCode],[HomePhone],[CellPhone],[WorkPhone],[FaxPhone],[Email],[BloodTypeID]
	--	   ,[OrganDonor],[HeightInches],[WeightLbs],[MaritalStatusID],[EconomicStatusID],[Occupation],[Hours]
	--	   ,[CreationDate],[ModifyDate],[MaxAttachmentLimit],[CreatedBy],[CreatedByOrganization],[UpdatedBy]
	--	   ,[UpdatedByOrganization],[UpdatedByContact],[Organization],[Language],[Ethnicity],[CreatedByNPI]
	--	   ,[UpdatedByNPI],[InCaseManagement],[NarcoticLockdown],[MiddleName]
 --  from MainPersonalDetails
 --  where ICENUMBER = @mvdid           

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
	
	--delete from MainPersonalDetails
	--where ICENUMBER = @mvdid  

	--IF @@ERROR <> 0
	--BEGIN
	--	ROLLBACK TRAN
	--	return 10
	--END
	
	if not exists(select mvdid from  MyVitalDataLIVE_Archive.dbo.Link_MemberId_MVD_Ins where MVDId = @mvdid)
	begin
		INSERT INTO MyVitalDataLIVE_Archive.dbo.Link_MemberId_MVD_Ins (MVDId,InsMemberId,Cust_ID,IsPrimary,Active)
		select MVDId,InsMemberId,Cust_ID,IsPrimary,Active 
		from Link_MemberId_MVD_Ins
		where MVDId = @mvdid           
	end

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		return 10
	END
	
	commit transaction @TranName			 
END