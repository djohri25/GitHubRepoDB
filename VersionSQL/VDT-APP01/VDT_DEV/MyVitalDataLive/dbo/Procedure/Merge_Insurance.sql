/****** Object:  Procedure [dbo].[Merge_Insurance]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/28/2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Merge_Insurance]
	@MVDID_1 varchar(20),	-- primary MVD record, updated based on record #2
	@MVDID_2 varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	if not exists(select top 1 RecordNumber from MainInsurance where ICENUMBER = @MVDID_1)
	begin
		insert into MainInsurance(ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,FaxPhone
           ,PolicyHolderName,GroupNumber,PolicyNumber,WebSite,InsuranceTypeID,CreationDate
           ,ModifyDate,Medicaid,MedicareNumber,HVID,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization
           ,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,UpdatedByNPI,EffectiveDate,TerminationDate)
		select @MVDID_1,Name,Address1,Address2,City,State,Postal,Phone,FaxPhone
           ,PolicyHolderName,GroupNumber,PolicyNumber,WebSite,InsuranceTypeID,CreationDate
           ,ModifyDate,Medicaid,MedicareNumber,HVID,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization
           ,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,UpdatedByNPI,EffectiveDate,TerminationDate
        from MainInsurance
        where ICENUMBER = @MVDID_2
	end
	else
	begin
		declare @recordNumber2 int, @hpName2 varchar(100), @policyNumber2 varchar(50),
			@recordNumber1 int, @modifyDateRec1 datetime, @modifyDateRec2 datetime 
	
		declare @tempInsurance1 table (
			RecordNumber int,ICENUMBER varchar(15),Name varchar(50),Address1 varchar(50),Address2 varchar(50),
			City varchar(50),State varchar(2),Postal varchar(5),Phone varchar(10),FaxPhone varchar(10),
			PolicyHolderName varchar(50),GroupNumber varchar(50),PolicyNumber varchar(50),WebSite varchar(200),
			InsuranceTypeID int,CreationDate datetime,ModifyDate datetime,Medicaid varchar(50),MedicareNumber varchar(50),
			HVID char(36),HVFlag int,ReadOnly bit,CreatedBy varchar(250),CreatedByOrganization varchar(250),
			UpdatedBy varchar(250),UpdatedByOrganization varchar(250),UpdatedByContact varchar(64),
			CreatedByNPI varchar(20),UpdatedByNPI varchar(20),EffectiveDate smalldatetime,TerminationDate smalldatetime,
			isProcessed bit default(0)
		)

		declare @tempInsurance2 table (
			RecordNumber int,ICENUMBER varchar(15),Name varchar(50),Address1 varchar(50),Address2 varchar(50),
			City varchar(50),State varchar(2),Postal varchar(5),Phone varchar(10),FaxPhone varchar(10),
			PolicyHolderName varchar(50),GroupNumber varchar(50),PolicyNumber varchar(50),WebSite varchar(200),
			InsuranceTypeID int,CreationDate datetime,ModifyDate datetime,Medicaid varchar(50),MedicareNumber varchar(50),
			HVID char(36),HVFlag int,ReadOnly bit,CreatedBy varchar(250),CreatedByOrganization varchar(250),
			UpdatedBy varchar(250),UpdatedByOrganization varchar(250),UpdatedByContact varchar(64),
			CreatedByNPI varchar(20),UpdatedByNPI varchar(20),EffectiveDate smalldatetime,TerminationDate smalldatetime,
			isProcessed bit default(0)
		)
	
		insert into @tempInsurance1(
			RecordNumber,ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,FaxPhone
           ,PolicyHolderName,GroupNumber,PolicyNumber,WebSite,InsuranceTypeID,CreationDate
           ,ModifyDate,Medicaid,MedicareNumber,HVID,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization
           ,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,UpdatedByNPI,EffectiveDate,TerminationDate)
		select RecordNumber,ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,FaxPhone
           ,PolicyHolderName,GroupNumber,PolicyNumber,WebSite,InsuranceTypeID,CreationDate
           ,ModifyDate,Medicaid,MedicareNumber,HVID,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization
           ,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,UpdatedByNPI,EffectiveDate,TerminationDate
        from MainInsurance
        where ICENUMBER = @MVDID_1

		insert into @tempInsurance2(
			RecordNumber,ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,FaxPhone
           ,PolicyHolderName,GroupNumber,PolicyNumber,WebSite,InsuranceTypeID,CreationDate
           ,ModifyDate,Medicaid,MedicareNumber,HVID,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization
           ,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,UpdatedByNPI,EffectiveDate,TerminationDate)
		select RecordNumber,ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone,FaxPhone
           ,PolicyHolderName,GroupNumber,PolicyNumber,WebSite,InsuranceTypeID,CreationDate
           ,ModifyDate,Medicaid,MedicareNumber,HVID,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization
           ,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,UpdatedByNPI,EffectiveDate,TerminationDate
        from MainInsurance
        where ICENUMBER = @MVDID_2
               
        while exists(select top 1 recordnumber from @tempInsurance2 where isProcessed = 0)
		begin		
		
			select top 1 
				@recordNumber2 = RecordNumber,
				@hpName2 = Name,
				@policyNumber2 = PolicyNumber,
				@modifyDateRec2 = ModifyDate
			from @tempInsurance2
			where isProcessed = 0	
	
			select top 1 @recordnumber1 = RecordNumber,
				@modifyDateRec1 = ModifyDate
			from @tempInsurance1
			where Name = @hpName2
				AND PolicyNumber = @policyNumber2
				
			if ISNULL(@recordNumber1,'') = '' OR (ISNULL(@recordNumber1,'') <> '' AND @modifyDateRec2 > @modifyDateRec1)
			begin
				delete from MainInsurance	
				where RecordNumber = @recordNumber1
			
				insert into MainInsurance(
					ICENUMBER
					,Name,Address1,Address2,City,State,Postal,Phone,FaxPhone
				   ,PolicyHolderName,GroupNumber,PolicyNumber,WebSite,InsuranceTypeID,CreationDate
				   ,ModifyDate,Medicaid,MedicareNumber,HVID,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization
				   ,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,UpdatedByNPI,EffectiveDate,TerminationDate)
				select @MVDID_1,
					Name,Address1,Address2,City,State,Postal,Phone,FaxPhone
				   ,PolicyHolderName,GroupNumber,PolicyNumber,WebSite,InsuranceTypeID,CreationDate
				   ,ModifyDate,Medicaid,MedicareNumber,HVID,HVFlag,ReadOnly,CreatedBy,CreatedByOrganization
				   ,UpdatedBy,UpdatedByOrganization,UpdatedByContact,CreatedByNPI,UpdatedByNPI,EffectiveDate,TerminationDate
				from @tempInsurance2
				where RecordNumber = @recordNumber2
			end
			
			select @recordNumber1 = null,
				@modifyDateRec1 = null
		
			update @tempInsurance2 set isProcessed = 1
			where RecordNumber = @recordNumber2			
		end
	end
END