/****** Object:  Procedure [dbo].[uspGetMessageNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 06/18/2020
-- Description:	Get all active message notes for a member by MVDID and/or NoteId
-- Exec uspGetMessageNote '160917303411AA78BDD4'
/*
Updates:

03/24/2021	Added restriction on Broadcast Chart History records. Only include broadcast note where member is registered mobile app user and broadcast is sent succcessfully.
*/
-- =============================================
CREATE PROCEDURE [dbo].[uspGetMessageNote]
	@MVDID varchar(50),
	@MessageNoteId bigint = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    if @MessageNoteId is not null
		begin
			select 
				mn.Id, 
				mn.NoteTypeId, 
				mn.LinkedNoteType, 
				mn.LinkedNoteId, 
				mn.Note, 
				mn.CreatedBy, 
				mn.CreatedDate, 
				mn.UpdatedBy,
				mn.UpdatedDate,
				mn.IsDeleted,
				mn.IsActive
			from Link_MessageMember lmm
			join Message m on lmm.MId = m.Id and lmm.MVDID = @MVDID
			join MessageNote mn on m.Id = mn.LinkedNoteId and mn.LinkedNoteType = 'Message'
			where mn.Id = @MessageNoteId and ISNULL(mn.IsActive, 0) = 1 and ISNULL(m.IsActive, 0) = 1
			order by mn.CreatedDate desc
		end
	else
		begin
			declare @bcmpStatus int;

			select @bcmpStatus = CodeID
			from Lookup_Generic_Code 
			where CodeTypeID = 28 and Label = 'Sent'

			select 
				mn.Id, 
				mn.NoteTypeId, 
				mn.LinkedNoteType, 
				mn.LinkedNoteId, 
				mn.Note, 
				mn.CreatedBy, 
				mn.CreatedDate, 
				mn.UpdatedBy,
				mn.UpdatedDate,
				mn.IsDeleted,
				mn.IsActive
			from Link_MessageMember lmm
			join Message m on lmm.MId = m.Id 
			join MessageNote mn on m.Id = mn.LinkedNoteId and mn.LinkedNoteType = 'Message'
			where lmm.MVDID = @MVDID
				and ISNULL(mn.IsActive, 0) = 1 and ISNULL(m.IsActive, 0) = 1
			union
			select
				mn.Id, 
				mn.NoteTypeId, 
				mn.LinkedNoteType, 
				mn.LinkedNoteId, 
				mn.Note, 
				mn.CreatedBy, 
				mn.CreatedDate, 
				mn.UpdatedBy,
				mn.UpdatedDate,
				mn.IsDeleted,
				mn.IsActive
			from Link_BroadcastMember lbm
			join BroadcastAlert ba on lbm.BAId = ba.Id
			join MessageNote mn on ba.Id = mn.LinkedNoteId and mn.LinkedNoteType = 'Broadcast'
			where lbm.MVDID = @MVDID
				and ISNULL(lbm.IsMemberMobileRegistered, 0) = 1
				and lbm.BroadcastStatusId = @bcmpStatus
				and ISNULL(mn.IsActive, 0) = 1 and ISNULL(ba.IsActive, 0) = 1
		end
END