/****** Object:  Procedure [dbo].[Del_HPPredefinedNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/25/2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Del_HPPredefinedNote]
	@username varchar(50),
	@noteID int
AS
BEGIN
	SET NOCOUNT ON;

	delete from dbo.HPAlertPredefinedNote
	where ID = @noteID
	
END