/****** Object:  Procedure [dbo].[Upd_Allergies]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_Allergies]

	@RecNum int,
	@AllgType int,
	@AllgName varchar(25),
	@AllgRec varchar(150),
	@UpdatedBy nvarchar(250) = NULL,
	@UpdatedByContact nvarchar(256) = NULL,
	@Organization nvarchar(64) = NULL

As

Set Nocount On

Update MainAllergies 
Set 
	AllergenTypeId = @AllgType,
	AllergenName = @AllgName,
	Reaction = @AllgRec,
	ModifyDate = GETUTCDATE(),
	UpdatedBy =@UpdatedBy,
	UpdatedByContact = @UpdatedByContact,
	UpdatedByOrganization = @Organization
Where RecordNumber = @RecNum