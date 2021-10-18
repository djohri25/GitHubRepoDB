/****** Object:  Procedure [dbo].[Set_AllergiesByEMS]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_AllergiesByEMS]

	@ICENUMBER varchar(15),
	@AllgType int,
	@AllgName varchar(25),
	@AllgRec varchar(50),
	@CreatedBy nvarchar(250) = NULL,
	@UpdatedBy nvarchar(250) = NULL,
	@UpdatedByContact nvarchar(256) = NULL,
	@Organization nvarchar(64) = NULL,
	@EmsID varchar(50),				-- ID of the person updating the record
	@Result int out					-- 0 - success, -1 - failure, -2 - duplicate allergy
as

Set NoCount On

declare @newRecordID int

set @Result = -1

begin try
	if exists (select recordnumber from MainAllergies 
		where icenumber = @icenumber 
			and allergenTypeId = @AllgType 
			and allergenName = @AllgName
			and Reaction = @AllgRec)
	begin
		set @Result = -2
	end
	else
	begin
		Insert Into MainAllergies (ICENUMBER, AllergenTypeId, AllergenName,
			Reaction, ModifyDate, CreationDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByContact,UpdatedByOrganization) 
		Values (@ICENUMBER, @AllgType, @AllgName,
			@AllgRec, GETUTCDATE(), GETUTCDATE(),@CreatedBy,@Organization,@UpdatedBy,@UpdatedByContact,@Organization )
	
		set @Result = 0
		set @newRecordID = scope_identity()

		-- Create the history of changes
		insert into MainAllergiesHistory
		(
			RecordNumber
		   ,[ICENUMBER]
		   ,[AllergenTypeId]
		   ,[AllergenName]
		   ,[Reaction]
		   ,[HVID]
		   ,[HVFlag]
		   ,[CreationDate]
		   ,[ModifyDate]
		   ,[ReadOnly]
		   ,[CreatedBy]
		   ,[CreatedByOrganization]
		   ,[UpdatedBy]
		   ,[UpdatedByOrganization]
		   ,[UpdatedByContact]
		   ,[Organization]
		)
		select 
			RecordNumber
		   ,[ICENUMBER]
		   ,[AllergenTypeId]
		   ,[AllergenName]
		   ,[Reaction]
		   ,[HVID]
		   ,[HVFlag]
		   ,[CreationDate]
		   ,[ModifyDate]
		   ,[ReadOnly]
		   ,[CreatedBy]
		   ,[CreatedByOrganization]
		   ,[UpdatedBy]
		   ,[UpdatedByOrganization]
		   ,[UpdatedByContact]
		   ,[Organization]
		from MainAllergies
		Where recordNumber = @newRecordID

		insert into dbo.EMS_MemberUpdateHistory
		(
			[EmployeeID]
		   ,[MvdID]
		   ,[SectionID]
		   ,[Action]
		   ,[Created]
		   ,[HistoryRecordID]
		   ,[MainRecordID]
		)
		values
		(
			@EMSID,
			@ICENUMBER,
			'ALLERGY',
			'ADD',
			getutcdate(),
			SCOPE_IDENTITY(),
			@newRecordID
		)

	end
end try
begin catch
	set @Result = -1
end catch