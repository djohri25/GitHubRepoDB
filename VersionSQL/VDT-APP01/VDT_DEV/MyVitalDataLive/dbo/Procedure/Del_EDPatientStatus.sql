/****** Object:  Procedure [dbo].[Del_EDPatientStatus]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:      Tim Thein
-- Create date: 10/6/2009
-- Description: Deletes only one row of EDPatientStatus
-- =============================================
CREATE PROCEDURE dbo.Del_EDPatientStatus
	@id INT
AS
BEGIN
	DELETE	EDPatientStatus
	WHERE	ID = @id
END