/****** Object:  Procedure [dbo].[Get_MDNoteRecipientGroups]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/19/2013
-- Description:	Get MD groups which chose to be notified about member notes
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDNoteRecipientGroups]
	@ShowAll bit
AS
BEGIN
	SET NOCOUNT ON;

	select ID, GroupName
	from MDGroup
	where IsNoteAlertGroup = 1
		and Active = 1
	order by GroupName
END