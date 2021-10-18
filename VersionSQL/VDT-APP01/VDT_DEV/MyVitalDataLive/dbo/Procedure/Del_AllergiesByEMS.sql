/****** Object:  Procedure [dbo].[Del_AllergiesByEMS]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Del_AllergiesByEMS]
	@ICENUMBER varchar(15),
	@AllgType int,
	@AllgName varchar(25),
	@AllgRec varchar(50),
	@EMSID varchar(50)		-- Currently NPI of doctor

as

set nocount on

declare @mainRecordID int

select @mainRecordId = recordNumber
from MainAllergies
where ICENUMBER = @ICENUMBER
	AND AllergenTypeId = @AllgType
	AND AllergenName = @AllgName
	AND Reaction = @AllgRec

if(@mainRecordID is not null AND @mainRecordID <> 0)
begin
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
	Where ICENUMBER = @ICENUMBER
		AND AllergenTypeId = @AllgType
		AND AllergenName = @AllgName
		AND Reaction = @AllgRec

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
		'DELETE',
		getutcdate(),
		SCOPE_IDENTITY(),
		@mainRecordID
	)

	Delete
	From MainAllergies
	Where ICENUMBER = @ICENUMBER
		AND AllergenTypeId = @AllgType
		AND AllergenName = @AllgName
		AND Reaction = @AllgRec

end