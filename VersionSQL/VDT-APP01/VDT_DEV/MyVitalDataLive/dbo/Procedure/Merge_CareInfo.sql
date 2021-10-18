/****** Object:  Procedure [dbo].[Merge_CareInfo]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 1/4/2011
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Merge_CareInfo]
	@MVDID_1 varchar(20),	-- primary MVD record, updated based on record #2
	@MVDID_2 varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	if not exists(select top 1 RecordNumber from MainCareInfo where ICENUMBER = @MVDID_1)
	begin
		insert into MainCareInfo(
			ICENUMBER,LastName,FirstName,Address1,Address2,City,State,Postal
           ,PhoneHome,PhoneCell,PhoneOther,CareTypeID,RelationshipId,CreationDate
           ,ModifyDate,HVID,ContactType,EmailAddress,NotifyByEmail,NotifyBySMS
           ,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
           ,UpdatedByContact,Organization,MiddleName)
		select @MVDID_1,LastName,FirstName,Address1,Address2,City,State,Postal
           ,PhoneHome,PhoneCell,PhoneOther,CareTypeID,RelationshipId,CreationDate
           ,ModifyDate,HVID,ContactType,EmailAddress,NotifyByEmail,NotifyBySMS
           ,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
           ,UpdatedByContact,Organization,MiddleName
        from MainCareInfo
        where ICENUMBER = @MVDID_2
	end
	else
	begin
		declare @recordNumber2 int, @firstName2 varchar(50), @lastName2 varchar(50),
			@recordNumber1 int, @modifyDate1 datetime, @modifyDate2 datetime  
	
		declare @tempCareInfo1 table (
			RecordNumber int,ICENUMBER varchar(15),LastName varchar(50),FirstName varchar(50),
			Address1 varchar(50),Address2 varchar(50),City varchar(50),State varchar(50),
			Postal varchar(50),PhoneHome varchar(10),PhoneCell varchar(10),PhoneOther varchar(10),
			CareTypeID int,RelationshipId int,CreationDate datetime,ModifyDate datetime,
			HVID char(36),ContactType varchar(20),EmailAddress varchar(100),NotifyByEmail bit,
			NotifyBySMS bit,CreatedBy nvarchar(250),CreatedByOrganization varchar(250),
			UpdatedBy nvarchar(250),UpdatedByOrganization varchar(250),UpdatedByContact nvarchar(64),
			Organization nvarchar(256),MiddleName nvarchar(50),
			isProcessed bit default(0)
		)

		declare @tempCareInfo2 table (
			RecordNumber int,ICENUMBER varchar(15),LastName varchar(50),FirstName varchar(50),
			Address1 varchar(50),Address2 varchar(50),City varchar(50),State varchar(50),
			Postal varchar(50),PhoneHome varchar(10),PhoneCell varchar(10),PhoneOther varchar(10),
			CareTypeID int,RelationshipId int,CreationDate datetime,ModifyDate datetime,
			HVID char(36),ContactType varchar(20),EmailAddress varchar(100),NotifyByEmail bit,
			NotifyBySMS bit,CreatedBy nvarchar(250),CreatedByOrganization varchar(250),
			UpdatedBy nvarchar(250),UpdatedByOrganization varchar(250),UpdatedByContact nvarchar(64),
			Organization nvarchar(256),MiddleName nvarchar(50),
			isProcessed bit default(0)
		)
	
		insert into @tempCareInfo1(
			RecordNumber,ICENUMBER,LastName,FirstName,Address1,Address2,City,State,Postal
           ,PhoneHome,PhoneCell,PhoneOther,CareTypeID,RelationshipId,CreationDate
           ,ModifyDate,HVID,ContactType,EmailAddress,NotifyByEmail,NotifyBySMS
           ,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
           ,UpdatedByContact,Organization,MiddleName)
		select RecordNumber,ICENUMBER,LastName,FirstName,Address1,Address2,City,State,Postal
           ,PhoneHome,PhoneCell,PhoneOther,CareTypeID,RelationshipId,CreationDate
           ,ModifyDate,HVID,ContactType,EmailAddress,NotifyByEmail,NotifyBySMS
           ,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
           ,UpdatedByContact,Organization,MiddleName
        from MainCareInfo
        where ICENUMBER = @MVDID_1

		insert into @tempCareInfo2(
			RecordNumber,ICENUMBER,LastName,FirstName,Address1,Address2,City,State,Postal
           ,PhoneHome,PhoneCell,PhoneOther,CareTypeID,RelationshipId,CreationDate
           ,ModifyDate,HVID,ContactType,EmailAddress,NotifyByEmail,NotifyBySMS
           ,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
           ,UpdatedByContact,Organization,MiddleName)
		select RecordNumber,ICENUMBER,LastName,FirstName,Address1,Address2,City,State,Postal
           ,PhoneHome,PhoneCell,PhoneOther,CareTypeID,RelationshipId,CreationDate
           ,ModifyDate,HVID,ContactType,EmailAddress,NotifyByEmail,NotifyBySMS
           ,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
           ,UpdatedByContact,Organization,MiddleName
        from MainCareInfo
        where ICENUMBER = @MVDID_2
               
        while exists(select top 1 recordnumber from @tempCareInfo2 where isProcessed = 0)
		begin			
			select top 1 
				@recordNumber2 = RecordNumber,
				@firstName2 = FirstName,
				@lastName2 = LastName,
				@modifyDate2 = ModifyDate
			from @tempCareInfo2
			where isProcessed = 0	
	
			select top 1 @recordnumber1 = RecordNumber,
				@modifyDate1 = ModifyDate
			from @tempCareInfo1
			where FirstName = @firstName2
				AND LastName = @lastName2
				
			if ISNULL(@recordNumber1,'') = '' OR (ISNULL(@recordNumber1,'') <> '' AND @modifyDate2 > @modifyDate1)
			begin
				delete from MainCareInfo	
				where RecordNumber = @recordNumber1
			
				insert into MainCareInfo(
					ICENUMBER
					,LastName,FirstName,Address1,Address2,City,State,Postal
				   ,PhoneHome,PhoneCell,PhoneOther,CareTypeID,RelationshipId,CreationDate
				   ,ModifyDate,HVID,ContactType,EmailAddress,NotifyByEmail,NotifyBySMS
				   ,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
				   ,UpdatedByContact,Organization,MiddleName)
				select @MVDID_1
					,LastName,FirstName,Address1,Address2,City,State,Postal
				   ,PhoneHome,PhoneCell,PhoneOther,CareTypeID,RelationshipId,CreationDate
				   ,ModifyDate,HVID,ContactType,EmailAddress,NotifyByEmail,NotifyBySMS
				   ,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByOrganization
				   ,UpdatedByContact,Organization,MiddleName
				from @tempCareInfo2
				where RecordNumber = @recordNumber2
			end
			
			select @recordNumber1 = null,
				@modifyDate1 = null
		
			update @tempCareInfo2 set isProcessed = 1
			where RecordNumber = @recordNumber2			
		end
	end
END