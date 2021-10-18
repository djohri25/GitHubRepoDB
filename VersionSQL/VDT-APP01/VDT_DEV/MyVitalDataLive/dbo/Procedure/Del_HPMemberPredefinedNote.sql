/****** Object:  Procedure [dbo].[Del_HPMemberPredefinedNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/25/2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Del_HPMemberPredefinedNote]
	@username varchar(50),
	@noteID int
AS
BEGIN
	SET NOCOUNT ON;

	delete from dbo.HPMemberPredefinedNote
	where ID = @noteID
	
END