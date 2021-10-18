/****** Object:  Procedure [dbo].[Upd_ImportSummaryByFile]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Upd_ImportSummaryByFile]
	@ImportType varchar(50),
	@SuccessfulCount int, 
	@FailedCount int,
	@NewMemberCount int,
	@UpdatedMemberCount int,
	@DeactivatedCount int,
	@DestinationDB varchar(50),
	@CustomerName varchar(50),
	@SourceFileName varchar(50)
AS
	SET @DestinationDB = DB_NAME()
	EXEC HPM_Import.dbo.Upd_ImportSummaryByFile
		@ImportType         = @ImportType,
		@SuccessfulCount	= @SuccessfulCount,
		@FailedCount		= @FailedCount,
		@NewMemberCount		= @NewMemberCount,
		@UpdatedMemberCount	= @UpdatedMemberCount,
		@DeactivatedCount	= @DeactivatedCount,
		@DestinationDB		= @DestinationDB,
		@CustomerName		= @CustomerName,
		@SourceFileName		= @SourceFileName
	RETURN