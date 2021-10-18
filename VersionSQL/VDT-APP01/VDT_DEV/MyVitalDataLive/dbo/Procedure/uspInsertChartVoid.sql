/****** Object:  Procedure [dbo].[uspInsertChartVoid]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 08/31/2020
-- Description:	Insert chart void of a member
-- =============================================
create PROCEDURE [dbo].[uspInsertChartVoid]
	@Id bigint = null,
	@MVDID varchar(50),
	@ChartEntityTypeId int,
	@ChartEntityId bigint,
	@RequestedBy varchar(250),
	@VoidReasonId int,
	@CreatedBy varchar(250),
	@CreatedDate datetime,
	@newId bigint = null output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @messageNoteTypeId int,
			@broadcastNoteTypeId int

	select @messageNoteTypeId = CodeID 
	from Lookup_Generic_Code 
	where CodeTypeID = 5 
		and Label = 'Message'

	select @broadcastNoteTypeId = CodeID 
	from Lookup_Generic_Code 
	where CodeTypeID = 5 
		and Label = 'Broadcast'

    INSERT INTO [dbo].[ChartVoid]
           (
				[MVDID]
				,[ChartEntityTypeId]
				,[ChartEntityId]
				,[RequestedBy]
				,[VoidReasonId]
				,[CreatedBy]
				,[CreatedDate]
			)
     VALUES
           (
				@MVDID,
				@ChartEntityTypeId,
				@ChartEntityId,
				@RequestedBy,
				@VoidReasonId,
				@CreatedBy,
				@CreatedDate
			)

	set @newId = SCOPE_IDENTITY();

	if @ChartEntityTypeId = @messageNoteTypeId or @ChartEntityTypeId = @broadcastNoteTypeId
		begin
			--update chart record of message
			update MessageNote 
			set Note = CONCAT('Void | ', IsNull(Note,'')),
				IsDeleted = 1,
				UpdatedBy = @CreatedBy,
				UpdatedDate = @CreatedDate
			where Id = @ChartEntityId
		end
	else
		begin
			--update chart record of HpAlertNote
			update HPAlertNote
			set Note = CONCAT('Void | ', IsNull(Note,'')),
				IsDelete = 1,
				ModifiedBy = @CreatedBy,
				DateModified = @CreatedDate
			where ID = CONVERT(int, @ChartEntityId)
		end
	
END