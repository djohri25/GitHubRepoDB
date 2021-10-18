/****** Object:  Procedure [dbo].[Upd_ImportSummary]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Upd_ImportSummary]
	@ImportType varchar(50),
	@SuccessfulCount int, 
	@FailedCount int,
	@NewMemberCount int,
	@UpdatedMemberCount int,
	@DeactivatedCount int,
	@DestinationDB varchar(50),
	@CustomerName varchar(50)
AS
	SET @DestinationDB = DB_NAME()
	EXEC HPM_Import.dbo.Upd_ImportSummary
		@ImportType         = @ImportType,
		@SuccessfulCount	= @SuccessfulCount,
		@FailedCount		= @FailedCount,
		@NewMemberCount		= @NewMemberCount,
		@UpdatedMemberCount	= @UpdatedMemberCount,
		@DeactivatedCount	= @DeactivatedCount,
		@DestinationDB		= @DestinationDB,
		@CustomerName		= @CustomerName
	RETURN