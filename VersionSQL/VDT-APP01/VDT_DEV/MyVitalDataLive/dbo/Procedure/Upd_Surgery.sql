/****** Object:  Procedure [dbo].[Upd_Surgery]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_Surgery] 

	@RecNum int,
	@YearDate datetime,
	@Condition varchar(50),
	@Treatment varchar(50),
	@UpdatedBy nvarchar(250) = NULL,
	@UpdatedByContact nvarchar(256) = NULL,
	@Organization nvarchar(64) = NULL

as
	SET NOCOUNT ON

	UPDATE MainSurgeries
	SET 
	YearDate = @YearDate,
	Condition = @Condition,
	Treatment = @Treatment,
	ModifyDate = GETUTCDATE(),
	UpdatedBy =@UpdatedBy,
	UpdatedByContact = @UpdatedByContact,
	UpdatedByOrganization=@Organization
	WHERE RecordNumber = @RecNum