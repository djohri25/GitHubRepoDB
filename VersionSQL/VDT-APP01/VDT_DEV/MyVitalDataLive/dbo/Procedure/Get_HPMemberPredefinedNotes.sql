/****** Object:  Procedure [dbo].[Get_HPMemberPredefinedNotes]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/25/2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPMemberPredefinedNotes]
	@username varchar(50),
	@custID varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	select n.ID as NoteID,ShortName, Note,
		s.Name as Status,
		StatusID
	from dbo.HPMemberPredefinedNote n
		inner join dbo.LookupHPMemberStatus s on n.statusID = s.ID
	where custID = @custID
	
END