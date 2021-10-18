/****** Object:  Procedure [dbo].[uspInsertMessageNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 06/18/2020
-- Description:	insert or update MessageNote for new or reply message or Broadcast Alert.
-- =============================================
CREATE PROCEDURE [dbo].[uspInsertMessageNote]
	@NoteTypeId int = null,
	@NoteType varchar(100),
	@MessageId bigint,
	@Note varchar(max) = null,
	@CreatedBy varchar(100),
	@CreatedDate datetime = null,
	@UpdatedBy varchar(100) = null,
	@UpdatedDate datetime = null,
	@IsDeleted bit = null,
	@IsActive bit = null,
	@MessageNoteId bigint output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @NoteTypeId is null
		begin
			select @NoteTypeId = CodeID from Lookup_Generic_Code where CodeTypeID = 5 and Label = @NoteType;
		end

	if @CreatedDate is null
		begin
			set @CreatedDate = GETUTCDATE();
		end

	Insert into MessageNote
		(
			NoteTypeId,
			LinkedNoteType,
			[LinkedNoteId],
			[Note],
			[CreatedBy],
			[CreatedDate],
			[UpdatedBy],
			[UpdatedDate],
			[IsDeleted],
			[IsActive]
		)
	values
		(
			@NoteTypeId,
			@NoteType,
			@MessageId,
			@Note,
			@CreatedBy,
			@CreatedDate,
			@UpdatedBy,
			@UpdatedDate,
			@IsDeleted,
			@IsActive
		);

	SET @MessageNoteId = SCOPE_IDENTITY();
    
END