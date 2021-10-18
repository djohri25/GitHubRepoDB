/****** Object:  Procedure [dbo].[Set_Surgery]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Set_Surgery]

	@ICENUMBER varchar(15),
	@YearDate datetime,
	@Condition varchar(50),
	@Treatment varchar(50),
	@CreatedBy nvarchar(250) = NULL,
	@UpdatedBy nvarchar(250) = NULL,
	@UpdatedByContact nvarchar(256) = NULL,
	@Organization nvarchar(64) = NULL

as

SET NOCOUNT ON
            
INSERT INTO MainSurgeries (ICENUMBER, YearDate, Condition, Treatment,
	CreationDate, ModifyDate,CreatedBy,CreatedByOrganization,UpdatedBy,UpdatedByContact,UpdatedByOrganization) 
VALUES (@ICENUMBER, @YearDate, @Condition,
	@Treatment, GETUTCDATE(), GETUTCDATE(),@CreatedBy,@Organization,@UpdatedBy,@UpdatedByContact,@Organization)