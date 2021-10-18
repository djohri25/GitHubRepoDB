/****** Object:  Procedure [dbo].[Merge_Specialist]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/28/2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Merge_Specialist]
	@MVDID_1 varchar(20),	-- primary MVD record, updated based on record #2
	@MVDID_2 varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	if not exists(select top 1 RecordNumber from MainSpecialist where ICENUMBER = @MVDID_1)
	begin
		insert into MainSpecialist(
			ICENUMBER,LastName,FirstName,Address1,Address2,City,State,Postal
			,Specialty,Phone,PhoneCell,FaxPhone,NurseName,NursePhone,RoleID
			,CreationDate,ModifyDate,NPI)
		select @MVDID_1,LastName,FirstName,Address1,Address2,City,State,Postal
			,Specialty,Phone,PhoneCell,FaxPhone,NurseName,NursePhone,RoleID
			,CreationDate,ModifyDate,NPI
        from MainSpecialist
        where ICENUMBER = @MVDID_2
	end
	else
	begin
		declare @recordNumber2 int, @firstName2 varchar(50), @lastName2 varchar(50),
			@recordNumber1 int, @modifyDateRec1 datetime, @modifyDateRec2 datetime 
	
		declare @tempSpecialist1 table (
			RecordNumber int,ICENUMBER varchar(15),LastName varchar(50),FirstName varchar(50),
			Address1 varchar(50),Address2 varchar(50),City varchar(50),State varchar(2),
			Postal varchar(5),Specialty varchar(50),Phone varchar(10),PhoneCell varchar(10),
			FaxPhone varchar(10),NurseName varchar(50),NursePhone varchar(10),RoleID int,
			CreationDate datetime,ModifyDate datetime,NPI varchar(20),
			isProcessed bit default(0)
		)

		declare @tempSpecialist2 table (
			RecordNumber int,ICENUMBER varchar(15),LastName varchar(50),FirstName varchar(50),
			Address1 varchar(50),Address2 varchar(50),City varchar(50),State varchar(2),
			Postal varchar(5),Specialty varchar(50),Phone varchar(10),PhoneCell varchar(10),
			FaxPhone varchar(10),NurseName varchar(50),NursePhone varchar(10),RoleID int,
			CreationDate datetime,ModifyDate datetime,NPI varchar(20),
			isProcessed bit default(0)
		)
	
		insert into @tempSpecialist1(
			RecordNumber,ICENUMBER,LastName,FirstName,Address1,Address2,City,State,Postal
			,Specialty,Phone,PhoneCell,FaxPhone,NurseName,NursePhone,RoleID
			,CreationDate,ModifyDate,NPI)
		select RecordNumber,ICENUMBER,LastName,FirstName,Address1,Address2,City,State,Postal
			,Specialty,Phone,PhoneCell,FaxPhone,NurseName,NursePhone,RoleID
			,CreationDate,ModifyDate,NPI
        from MainSpecialist
        where ICENUMBER = @MVDID_1

		insert into @tempSpecialist2(
			RecordNumber,ICENUMBER,LastName,FirstName,Address1,Address2,City,State,Postal
			,Specialty,Phone,PhoneCell,FaxPhone,NurseName,NursePhone,RoleID
			,CreationDate,ModifyDate,NPI)
		select RecordNumber,ICENUMBER,LastName,FirstName,Address1,Address2,City,State,Postal
			,Specialty,Phone,PhoneCell,FaxPhone,NurseName,NursePhone,RoleID
			,CreationDate,ModifyDate,NPI
        from MainSpecialist
        where ICENUMBER = @MVDID_2
               
        while exists(select top 1 recordnumber from @tempSpecialist2 where isProcessed = 0)
		begin		
		
			select top 1 
				@recordNumber2 = RecordNumber,
				@firstName2 = FirstName,
				@lastName2 = lastname,
				@modifyDateRec2 = ModifyDate
			from @tempSpecialist2
			where isProcessed = 0	
	
			select top 1 @recordnumber1 = RecordNumber,
				@modifyDateRec1 = ModifyDate
			from @tempSpecialist1
			where firstName = @firstName2
				AND LastName = @lastName2
				
			if ISNULL(@recordNumber1,'') = '' OR (ISNULL(@recordNumber1,'') <> '' AND @modifyDateRec2 > @modifyDateRec1)
			begin
				delete from MainSpecialist	
				where RecordNumber = @recordNumber1
			
				insert into MainSpecialist(
					ICENUMBER
					,LastName,FirstName,Address1,Address2,City,State,Postal
					,Specialty,Phone,PhoneCell,FaxPhone,NurseName,NursePhone,RoleID
					,CreationDate,ModifyDate,NPI)
				select @MVDID_1,
					LastName,FirstName,Address1,Address2,City,State,Postal
					,Specialty,Phone,PhoneCell,FaxPhone,NurseName,NursePhone,RoleID
					,CreationDate,ModifyDate,NPI
				from @tempSpecialist2
				where RecordNumber = @recordNumber2
			end
			
			select @recordNumber1 = null,
				@modifyDateRec1 = null
		
			update @tempSpecialist2 set isProcessed = 1
			where RecordNumber = @recordNumber2			
		end
	end
END