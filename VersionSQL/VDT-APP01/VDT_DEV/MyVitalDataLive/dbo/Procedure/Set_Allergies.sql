/****** Object:  Procedure [dbo].[Set_Allergies]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_Allergies]

	@ICENUMBER varchar(15),
	@AllgType int,
	@AllgName varchar(25),
	@AllgRec varchar(50),
	@CreatedBy nvarchar(250) = NULL,
	@UpdatedBy nvarchar(250) = NULL,
	@UpdatedByContact nvarchar(256) = NULL,
	@Organization nvarchar(64) = NULL,
	@Result int out					-- 0 - success, -1 - failure, -2 - duplicate allergy
as

Set NoCount On

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
	end
end try
begin catch
	set @Result = -1
end catch