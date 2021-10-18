/****** Object:  Procedure [dbo].[ArchiveMergedRecord]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 1/7/2011
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[ArchiveMergedRecord]
	@MVDID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @sql varchar(4000), @archiveDBName varchar(50)
	declare @temp table(data varchar(50))
	
	select @archiveDBName = dbo.Get_ArchiveDBName()	

	set @sql = 'select mvdid from ' + @archiveDBName + '.dbo.Link_MemberId_MVD_Ins where MVDId = ''' + @MVDID + ''''

	insert into @temp(data)
	EXEC (@sql)

	if not exists(select DATA from @temp)
	begin
		declare @icegroup varchar(20)
		
		delete from @temp
		
		set @sql = 'select ICEGROUP from MainICENUMBERGroups where ICENUMBER = ''' + @MVDID + ''''
		
		insert into @temp(data)
		EXEC (@sql)

		select @icegroup = data
		from @temp
				
		set @sql = 'INSERT INTO ' + @archiveDBName + '.dbo.MainICEGROUP (ICEGROUP, GroupName, SoftwareKey, GroupMax, CreationDate, ModifyDate) 
			select ICEGROUP, GroupName, SoftwareKey, GroupMax, CreationDate, ModifyDate
			from MainICEGROUP
			where ICEGROUP = ''' + @icegroup + ''''
	
		EXEC (@sql)
		
		set @sql = 'INSERT INTO ' + @archiveDBName + '.dbo.MainICENUMBERGroups (ICEGROUP, ICENUMBER, MainAccount, CreationDate, ModifyDate) 
			select ICEGROUP, ICENUMBER, MainAccount, CreationDate, ModifyDate
			from MainICENUMBERGroups
			where ICENUMBER = ''' + @MVDID + ''''
	
		EXEC (@sql)
				
		set @sql = 'insert into ' + @archiveDBName + '.dbo.UserAdditionalInfo
				(MVDID,IsPackageSent,LastUpdate,WasLoggedIn,SurveyShowAlways,HealthPlanUserNote
			   ,HealthPlanNoteLastUpdate)
			select MVDID,IsPackageSent,LastUpdate,WasLoggedIn,SurveyShowAlways,HealthPlanUserNote
			   ,HealthPlanNoteLastUpdate
			from UserAdditionalInfo
			where MVDID = ''' + @MVDID + ''''
	
		EXEC (@sql)
		       
		set @sql = 'insert into ' + @archiveDBName + '.dbo.SectionPermission
				(ICENUMBER,SectionID,IsPermitted,CreationDate,ModifyDate)
			select ICENUMBER,SectionID,IsPermitted,CreationDate,ModifyDate 
			from SectionPermission 	
			where ICENUMBER = ''' + @MVDID + ''''	
	
		EXEC (@sql)
				
		set @sql = 'insert into ' + @archiveDBName + '.dbo.MainPersonalDetails
				(ICENUMBER,LastName,FirstName,GenderID,SSN,DOB,Address1,Address2,City
			   ,State,PostalCode,HomePhone,CellPhone,WorkPhone,FaxPhone,Email
			   ,BloodTypeID,OrganDonor,HeightInches,WeightLbs,MaritalStatusID
			   ,EconomicStatusID,Occupation,Hours,CreationDate,ModifyDate,MaxAttachmentLimit
			   ,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			   ,UpdatedByContact,Organization,Language,Ethnicity,CreatedByNPI
			   ,UpdatedByNPI,InCaseManagement,NarcoticLockdown,MiddleName)
			select ICENUMBER,LastName,FirstName,GenderID,SSN,DOB,Address1,Address2,City
			   ,State,PostalCode,HomePhone,CellPhone,WorkPhone,FaxPhone,Email
			   ,BloodTypeID,OrganDonor,HeightInches,WeightLbs,MaritalStatusID
			   ,EconomicStatusID,Occupation,Hours,CreationDate,ModifyDate,MaxAttachmentLimit
			   ,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			   ,UpdatedByContact,Organization,Language,Ethnicity,CreatedByNPI
			   ,UpdatedByNPI,InCaseManagement,NarcoticLockdown,MiddleName
			from MainPersonalDetails 
			where ICENUMBER = ''' + @MVDID + ''''
	
		EXEC (@sql)
				
		set @sql = 'insert into ' + @archiveDBName + '.dbo.MainMedication
			(ICENUMBER,StartDate,StopDate,RefillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem
			   ,RxPharmacy,HowMuch,HowOften,WhyTaking,HVID,CreationDate,ModifyDate,ApproxDate
			   ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			   ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,Strength,Route)
			select ICENUMBER,StartDate,StopDate,RefillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem
			   ,RxPharmacy,HowMuch,HowOften,WhyTaking,HVID,CreationDate,ModifyDate,ApproxDate
			   ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			   ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,Strength,Route
			from MainMedication
			where ICENUMBER = ''' + @MVDID + ''''
        	
		EXEC (@sql)
		
		set @sql = 'insert into ' + @archiveDBName + '.dbo.MainMedicationHistory
			(ICENUMBER,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,
			   CreationDate,ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI)
			select ICENUMBER,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,
			   CreationDate,ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI
			from MainMedicationHistory
			where ICENUMBER = ''' + @MVDID + ''''
                	
		EXEC (@sql)
		
		set @sql = 'insert into ' + @archiveDBName + '.dbo.MainInsurance
			(ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,FaxPhone
			   ,PolicyHolderName,GroupNumber,PolicyNumber,WebSite,InsuranceTypeID,CreationDate
			   ,ModifyDate,Medicaid,MedicareNumber,HVID,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization
			   ,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,UpdatedByNPI,EffectiveDate,TerminationDate)
			select ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,FaxPhone
			   ,PolicyHolderName,GroupNumber,PolicyNumber,WebSite,InsuranceTypeID,CreationDate
			   ,ModifyDate,Medicaid,MedicareNumber,HVID,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization
			   ,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,UpdatedByNPI,EffectiveDate,TerminationDate
			from MainInsurance
			where ICENUMBER = ''' + @MVDID + ''''
        	
		EXEC (@sql)
		
		set @sql = 'insert into ' + @archiveDBName + '.dbo.MainCondition(ICENUMBER,ConditionId,OtherName,Code,CodingSystem
			   ,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			   ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,HVID,HVFlag,ReadOnly,ModifyDate
			   ,LabDataRefID,LabDataSourceName)
			select ICENUMBER,ConditionId,OtherName,Code,CodingSystem
			   ,ReportDate,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			   ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,HVID,HVFlag,ReadOnly,ModifyDate
			   ,LabDataRefID,LabDataSourceName
			from MainCondition
			where ICENUMBER = ''' + @MVDID + ''''        
        	
		EXEC (@sql)
        
		set @sql = 'insert into ' + @archiveDBName + '.dbo.MainCareInfo(
				ICENUMBER,LastName,FirstName,Address1,Address2,City,State,Postal
			   ,PhoneHome,PhoneCell,PhoneOther,CareTypeID,RelationshipId,CreationDate
			   ,ModifyDate,HVID,ContactType,EmailAddress,NotifyByEmail,NotifyBySMS
			   ,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			   ,UpdatedByContact,Organization,MiddleName)
			select ICENUMBER,LastName,FirstName,Address1,Address2,City,State,Postal
			   ,PhoneHome,PhoneCell,PhoneOther,CareTypeID,RelationshipId,CreationDate
			   ,ModifyDate,HVID,ContactType,EmailAddress,NotifyByEmail,NotifyBySMS
			   ,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			   ,UpdatedByContact,Organization,MiddleName
			from MainCareInfo
			where ICENUMBER = ''' + @MVDID + ''''
        	
		EXEC (@sql)
		
		set @sql = 'insert into ' + @archiveDBName + '.dbo.MainSurgeries(
				ICENUMBER,YearDate,Condition,Treatment,Code,CodingSystem,HVID,CreationDate,ModifyDate
			   ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			  ,UpdatedByContact,CreatedByNPI,UpdatedByNPI)
			select ICENUMBER,YearDate,Condition,Treatment,Code,CodingSystem,HVID,CreationDate,ModifyDate
			   ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
			  ,UpdatedByContact,CreatedByNPI,UpdatedByNPI
			from MainSurgeries
			where ICENUMBER = ''' + @MVDID + ''''
        	
		EXEC (@sql)
		
		set @sql = 'insert into ' + @archiveDBName + '.dbo.MainSpecialist(
				ICENUMBER,LastName,FirstName,Address1,Address2,City,State,Postal
				,Specialty,Phone,PhoneCell,FaxPhone,NurseName,NursePhone,RoleID
				,CreationDate,ModifyDate,NPI)
			select ICENUMBER,LastName,FirstName,Address1,Address2,City,State,Postal
				,Specialty,Phone,PhoneCell,FaxPhone,NurseName,NursePhone,RoleID
				,CreationDate,ModifyDate,NPI
			from MainSpecialist
			where ICENUMBER = ''' + @MVDID + ''''
        	
		EXEC (@sql)
		
		set @sql = 'insert into ' + @archiveDBName + '.dbo.MainLabRequest(ICENUMBER,OrderID,OrderName,OrderCode,OrderCodingSystem
				,RequestDate,OrderingPhysicianFirstName,OrderingPhysicianLastName
				,OrderingPhysicianID,ProcedureName,ProcedureCode,ProcedureCodingSystem
				,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
				,UpdatedByContact,CreatedByNPI,UpdatedByNPI,SourceName)
			select ICENUMBER,OrderID,OrderName,OrderCode,OrderCodingSystem
				,RequestDate,OrderingPhysicianFirstName,OrderingPhysicianLastName
				,OrderingPhysicianID,ProcedureName,ProcedureCode,ProcedureCodingSystem
				,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
				,UpdatedByContact,CreatedByNPI,UpdatedByNPI,SourceName
			from MainLabRequest
			where ICENUMBER = ''' + @MVDID + ''''
        	
		EXEC (@sql)
		
		set @sql = 'insert into ' + @archiveDBName + '.dbo.MainLabResult(ICENUMBER,OrderID,ResultID,ResultName,Code
				,CodingSystem,ResultValue,ResultUnits,RangeLow,RangeHigh,RangeAlpha
				,AbnormalFlag,ReportedDate,Notes,CreationDate,CreatedBy,CreatedByOrganization
				,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI
				,UpdatedByNPI,SourceName)
			select ICENUMBER,OrderID,ResultID,ResultName,Code,CodingSystem,ResultValue
				,ResultUnits,RangeLow,RangeHigh,RangeAlpha,AbnormalFlag,ReportedDate
				,Notes,CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy
				,UpdatedByOrganization,UpdatedByContact,CreatedByNPI
				,UpdatedByNPI,SourceName
			from MainLabResult
			where ICENUMBER = ''' + @MVDID + ''''
        	
		EXEC (@sql)
		
		set @sql = 'insert into ' + @archiveDBName + '.dbo.MainLabNote(ICENUMBER,ResultID,Note,CreationDate,CreatedBy
				,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact
				,CreatedByNPI,UpdatedByNPI,SourceName,SequenceNum)
			select ICENUMBER,ResultID,Note,CreationDate,CreatedBy
				,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact
				,CreatedByNPI,UpdatedByNPI,SourceName,SequenceNum
			from MainLabNote
			where ICENUMBER = ''' + @MVDID + ''''   
        	
		EXEC (@sql)
		
		set @sql = 'insert into ' + @archiveDBName + '.dbo.MainDiseaseManagement(ICENUMBER,Created,DM_ID,name)
			select ICENUMBER,Created,DM_ID,name
			from MainDiseaseManagement
			where ICENUMBER = ''' + @MVDID + ''''
        	
		EXEC (@sql)
		
		set @sql = 'insert into ' + @archiveDBName + '.dbo.Link_MemberId_MVD_Ins(MVDId,InsMemberId,Cust_ID,Created)
			select MVDId,InsMemberId,Cust_ID,Created
			from Link_MemberId_MVD_Ins
			where MVDId = ''' + @MVDID + ''''      
        	
		EXEC (@sql)
		
		set @sql = 'insert into ' + @archiveDBName + '.dbo.EdVisitHistory(id,ICENUMBER,VisitDate,FacilityName,PhysicianFirstName,PhysicianLastName
				,PhysicianPhone,Source,SourceRecordID,Created,CancelNotification
				,CancelNotifyReason,IsHospitalAdmit,VisitType,SourceFormType,MatchName
				,MatchRecordID,FacilityNPI,POS)
			select ID,ICENUMBER,VisitDate,FacilityName,PhysicianFirstName,PhysicianLastName
				,PhysicianPhone,Source,SourceRecordID,Created,CancelNotification
				,CancelNotifyReason,IsHospitalAdmit,VisitType,SourceFormType,MatchName
				,MatchRecordID,FacilityNPI,POS
			from EdVisitHistory
			where ICENUMBER = ''' + @MVDID + ''''  
        	
		EXEC (@sql)
		
		set @sql = 'INSERT INTO ' + @archiveDBName + '.dbo.MD_Alert
			   (ID,MVDID,DoctorID,AlertDate,Facility,Text,StatusID,RecordAccessID
			   ,ChiefComplaint,EMSNote,Created)
			select ID,MVDID,DoctorID,AlertDate,Facility,Text,StatusID,RecordAccessID
			   ,ChiefComplaint,EMSNote,Created
			from MD_Alert 
			where MVDID = ''' + @MVDID + ''''
			
		EXEC (@sql)
		
		set @sql = 'INSERT INTO ' + @archiveDBName + '.dbo.MD_Note
			   (ID,MvdID,Text,CreatedByUserID,Created,ModifyByUserID,ModifyDate)
			select ID,MvdID,Text,CreatedByUserID,Created,ModifyByUserID,ModifyDate
			from MD_Note               
			where MvdID = ''' + @MVDID + ''''
			
		EXEC (@sql)
		
		set @sql = 'INSERT INTO ' + @archiveDBName + '.dbo.MVD_AppRecord
			   (RecordID,AppId,LocationID,UserName,AccessReason,Action,MVDID
			   ,Criteria,ResultStatus,ResultCount,Created,AlertSendDate
			   ,ChiefComplaint,EMSNote,CancelNotification,CancelNotifyReason
			   ,Status,UserFacilityID)
			select RecordID,AppId,LocationID,UserName,AccessReason,Action,MVDID
			   ,Criteria,ResultStatus,ResultCount,Created,AlertSendDate
			   ,ChiefComplaint,EMSNote,CancelNotification,CancelNotifyReason
			   ,Status,UserFacilityID
			from MVD_AppRecord
			where MVDID = ''' + @MVDID + ''''
        	
		EXEC (@sql)
		
		set @sql = 'INSERT INTO ' + @archiveDBName + '.dbo.MVD_AppRecord_MD
			   (RecordID,AppId,LocationID,UserName,AccessReason,Action,MVDID
			   ,Criteria,ResultStatus,ResultCount,Created,AlertSendDate
			   ,ChiefComplaint,EMSNote,CancelNotification,CancelNotifyReason
			   ,Status,UserFacilityID)
			 select RecordID,AppId,LocationID,UserName,AccessReason,Action,MVDID
				   ,Criteria,ResultStatus,ResultCount,Created,AlertSendDate
				   ,ChiefComplaint,EMSNote,CancelNotification,CancelNotifyReason
				   ,Status,UserFacilityID
			 from MVD_AppRecord_MD
			 where MVDID = ''' + @MVDID + ''''
        	
		EXEC (@sql)
		
		set @sql = 'INSERT INTO ' + @archiveDBName + '.dbo.Link_HPMember_Doctor
			   (MVDID,Doctor_Id,DoctorFirstName,DoctorLastName,Created)
			select MVDID,Doctor_Id,DoctorFirstName,DoctorLastName,Created
			from Link_HPMember_Doctor
			where MVDID = ''' + @MVDID + ''''               
			
		EXEC (@sql)
	end
END