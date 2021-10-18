/****** Object:  Procedure [dbo].[Merge_Medications]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/29/2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Merge_Medications]
	@MVDID_1 varchar(20),	-- primary MVD record, updated based on record #2
	@MVDID_2 varchar(20)
	--,
	--@Action varchar(50),	-- 'Merge' - new record is created (@NewMVDID) from more recently updated (1 or 2)
	--						-- 'Update' - record 1  is primary record and is updated  from record 2 only
	--						--		if record 2 was more recently updated 
	--@NewMVDID varchar(20)	-- it's values if Action = 'Merge'
AS
BEGIN
	SET NOCOUNT ON;

	if not exists(select top 1 RecordNumber from MainMedication where ICENUMBER = @MVDID_1)
	begin
		insert into MainMedication(ICENUMBER,StartDate,StopDate,RefillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem
           ,RxPharmacy,HowMuch,HowOften,WhyTaking,HVID,CreationDate,ModifyDate,ApproxDate
           ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
           ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,Strength,Route)
		select @MVDID_1,StartDate,StopDate,RefillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem
           ,RxPharmacy,HowMuch,HowOften,WhyTaking,HVID,CreationDate,ModifyDate,ApproxDate
           ,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
           ,UpdatedByContact,CreatedByNPI,UpdatedByNPI,Strength,Route
        from MainMedication
        where ICENUMBER = @MVDID_2
        
        insert into MainMedicationHistory(ICENUMBER,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,
           CreationDate,ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI)
        select @MVDID_1,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,
           CreationDate,ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI
        from MainMedicationHistory
        where ICENUMBER = @MVDID_2
	end
	else
	begin
		declare @recordNumber2 int, @ICENUMBER2 varchar(20), @StartDate2 datetime,@refillDate2 datetime,
			@PrescribedBy2 varchar(100),@NDC2 varchar(20),
			@recordNumber1 int, @StartDate1 datetime,@refillDate1 datetime
	
		declare @tempMedication1 table (
			RecordNumber int,ICENUMBER varchar(15),StartDate datetime,StopDate datetime,RefillDate datetime,
			PrescribedBy varchar(50),DrugId varchar(1),RxDrug varchar(100),Code varchar(20),CodingSystem varchar(50),
			RxPharmacy varchar(100),HowMuch varchar(50),HowOften varchar(50),WhyTaking varchar(50),HVID char(36),
			CreationDate datetime,ModifyDate datetime,ApproxDate bit,HVFlag tinyint,ReadOnly bit,CreatedBy nvarchar(250),
			CreatedByOrganization varchar(250),UpdatedBy nvarchar(250),UpdatedByOrganization varchar(250),UpdatedByContact nvarchar(64),
			CreatedByNPI varchar(20),UpdatedByNPI varchar(20),Strength nvarchar(50),Route nvarchar(50)		
		)

		declare @tempMedication2 table (
			RecordNumber int,ICENUMBER varchar(15),StartDate datetime,StopDate datetime,RefillDate datetime,
			PrescribedBy varchar(50),DrugId varchar(1),RxDrug varchar(100),Code varchar(20),CodingSystem varchar(50),
			RxPharmacy varchar(100),HowMuch varchar(50),HowOften varchar(50),WhyTaking varchar(50),HVID char(36),
			CreationDate datetime,ModifyDate datetime,ApproxDate bit,HVFlag tinyint,ReadOnly bit,CreatedBy nvarchar(250),
			CreatedByOrganization varchar(250),UpdatedBy nvarchar(250),UpdatedByOrganization varchar(250),UpdatedByContact nvarchar(64),
			CreatedByNPI varchar(20),UpdatedByNPI varchar(20),Strength nvarchar(50),Route nvarchar(50),
			isProcessed bit default(0)		
		)
		
		declare @tempMedicationHistory1 table(
			RecordNumber int,ICENUMBER varchar(15),FillDate datetime,PrescribedBy varchar(50),DrugId varchar(1),
			RxDrug varchar(100),Code varchar(20),CodingSystem varchar(50),RxPharmacy varchar(100),CreationDate datetime,
			ImportRecordID int,CreatedBy varchar(250),CreatedByOrganization varchar(250),CreatedByContact varchar(50),CreatedByNPI varchar(20)		
		)
		
		declare @tempMedicationHistory2 table(
			RecordNumber int,ICENUMBER varchar(15),FillDate datetime,PrescribedBy varchar(50),DrugId varchar(1),
			RxDrug varchar(100),Code varchar(20),CodingSystem varchar(50),RxPharmacy varchar(100),CreationDate datetime,
			ImportRecordID int,CreatedBy varchar(250),CreatedByOrganization varchar(250),CreatedByContact varchar(50),CreatedByNPI varchar(20),
			isProcessed bit default(0)				
		)

		insert into @tempMedication1(		
			RecordNumber,ICENUMBER,StartDate,StopDate,RefillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,
			RxPharmacy,HowMuch,HowOften,WhyTaking,HVID,CreationDate,ModifyDate,ApproxDate,HVFlag,ReadOnly,
			CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,
			UpdatedByNPI,Strength,Route		
		)
		select RecordNumber,ICENUMBER,StartDate,StopDate,RefillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,
			RxPharmacy,HowMuch,HowOften,WhyTaking,HVID,CreationDate,ModifyDate,ApproxDate,HVFlag,ReadOnly,
			CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,
			UpdatedByNPI,Strength,Route
		from MainMedication
		where ICENUMBER = @MVDID_1
		
		insert into @tempMedication2(		
			RecordNumber,ICENUMBER,StartDate,StopDate,RefillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,
			RxPharmacy,HowMuch,HowOften,WhyTaking,HVID,CreationDate,ModifyDate,ApproxDate,HVFlag,ReadOnly,
			CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,
			UpdatedByNPI,Strength,Route		
		)
		select RecordNumber,ICENUMBER,StartDate,StopDate,RefillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,
			RxPharmacy,HowMuch,HowOften,WhyTaking,HVID,CreationDate,ModifyDate,ApproxDate,HVFlag,ReadOnly,
			CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,
			UpdatedByNPI,Strength,Route
		from MainMedication
		where ICENUMBER = @MVDID_2
		
		while exists(select top 1 recordnumber from @tempMedication2 where isProcessed = 0)
		begin		
			select top 1 
				@recordNumber2 = RecordNumber,
				@ICENUMBER2 = ICENUMBER,
				@StartDate2 = StartDate,
				@refillDate2 = RefillDate,
				@PrescribedBy2 = PrescribedBy,
				@NDC2 = Code
			from @tempMedication2
			where isProcessed = 0	
		
			select top 1 @recordnumber1 = RecordNumber,
				@StartDate1 = StartDate,
				@refillDate1 = RefillDate 
			from @tempMedication1 
			where Code = @NDC2
				
			if ISNULL(@recordNumber1,'') = ''
			begin
				insert into MainMedication (ICENUMBER,StartDate,StopDate,RefillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,
					RxPharmacy,HowMuch,HowOften,WhyTaking,HVID,CreationDate,ModifyDate,ApproxDate,HVFlag,ReadOnly,
					CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,
					UpdatedByNPI,Strength,Route		
				)
				select @MVDID_1,StartDate,StopDate,RefillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,
					RxPharmacy,HowMuch,HowOften,WhyTaking,HVID,CreationDate,ModifyDate,ApproxDate,HVFlag,ReadOnly,
					CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,
					UpdatedByNPI,Strength,Route
				from @tempMedication2
				where RecordNumber = @recordNumber2
			end
			else
			begin
				-- compare start and refill dates
				-- as of 1/3/2011 only compare refill
				
				if(@refillDate2 is null)
				begin
					set @refillDate2 = @StartDate2
				end
				
				IF @refillDate1 IS NULL
				begin
-- TODO: compare refilldate 2 because setting most recent refill date is more important than start date

-- TODO: when updating record also update data provider
					-- Never refilled before
					IF @refillDate2 < @StartDate1
					begin
						-- Incoming fill date is older than start date
						-- Reverse those 2 fields, since we want to know when memeber started taking the med
						-- Prescriber stays the same, as the most recent. Same with record owner (updater)
						update MainMedication set StartDate = @refillDate2, RefillDate = @StartDate1,
							ModifyDate = (getutcdate())
						where RecordNumber = @recordNumber1
					end
					ELSE IF @refillDate2 > @StartDate1
					begin
						-- First refill
						update MainMedication set RefillDate = @refillDate2, PrescribedBy = @PrescribedBy2, 
							ModifyDate = (GETUTCDATE())
						where RecordNumber = @recordNumber1
					end
					--else
					--begin
						-- Same day refill, ignore
					--end
				end
				else
				begin	
					-- Med was refilled before
					-- Set owner/Updater whoever prescribed the med most recently
					IF @refillDate2 < @StartDate1
					begin
						update MainMedication set StartDate = @refillDate2, 
							ModifyDate = (GETUTCDATE())
						where RecordNumber = @recordNumber1
					end
					--ELSE IF @StartDate1 <= @refillDate2 AND @refillDate2 < @tempRefillDate
					--begin
					--	-- Between start and refill, ignore
					--	set @Action = 'I'
					--end
					ELSE IF @refillDate1 < @refillDate2
					begin
						-- Newer refill
						update MainMedication set RefillDate = @refillDate2, PrescribedBy = @PrescribedBy2,
							ModifyDate = GETUTCDATE() 
						where RecordNumber = @recordNumber1
					end
				end
	
				
			end
		
			select @recordNumber1 = null,
				@StartDate1 = null,
				@refillDate1 = null
		
			update @tempMedication2 set isProcessed = 1
			where RecordNumber = @recordNumber2
		end	
		
		-- MEDICATION HISTORY
		insert into @tempMedicationHistory1(
			RecordNumber,ICENUMBER,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,CreationDate,
			ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI
		)
		select RecordNumber,ICENUMBER,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,CreationDate,
			ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI
		from MainMedicationHistory
		where ICENUMBER = @MVDID_1

		insert into @tempMedicationHistory2(
			RecordNumber,ICENUMBER,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,CreationDate,
			ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI
		)
		select RecordNumber,ICENUMBER,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,CreationDate,
			ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI
		from MainMedicationHistory
		where ICENUMBER = @MVDID_2
		
		
		if not exists(select recordNumber from @tempMedicationHistory1)
		begin
			insert into MainMedicationHistory(
				ICENUMBER,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,CreationDate,
				ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI
			)
			select @MVDID_1,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,CreationDate,
				ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI
			from @tempMedicationHistory2
		end
		else
		begin	
			select @NDC2 = null,
				@refillDate2 = null
				
			while exists (select recordNumber from @tempMedicationHistory2 where isProcessed = 0)
			begin
				select top 1 @recordNumber2 = recordnumber,
					@NDC2 = Code,
					@refillDate2 = FillDate
				from @tempMedicationHistory2
				where isProcessed = 0
				
				if not exists(select top 1 recordnumber from @tempMedicationHistory1
					where FillDate = @refillDate2 and Code = @NDC2)
				begin
					insert into MainMedicationHistory(
						ICENUMBER,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,CreationDate,
						ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI
					)
					select @MVDID_1,FillDate,PrescribedBy,DrugId,RxDrug,Code,CodingSystem,RxPharmacy,CreationDate,
						ImportRecordID,CreatedBy,CreatedByOrganization,CreatedByContact,CreatedByNPI
					from @tempMedicationHistory2					
					where RecordNumber = @recordNumber2
				end
				
				update @tempMedicationHistory2 
				set isProcessed = 1
				where RecordNumber = @recordNumber2
			end
		end		
	end
END