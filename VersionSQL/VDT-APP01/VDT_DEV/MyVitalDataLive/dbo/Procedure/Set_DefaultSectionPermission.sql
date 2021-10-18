/****** Object:  Procedure [dbo].[Set_DefaultSectionPermission]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Sets Default value for a section only if the record for that section
	doesn't exist in the table. Otherwise, do nothing
*/
CREATE PROCEDURE [dbo].[Set_DefaultSectionPermission]
	@IceNumber Varchar(15),
	@SectionId int
AS
BEGIN

	SET NOCOUNT ON

	IF NOT EXISTS(SELECT IceNumber FROM SectionPermission WHERE IceNumber = @IceNumber 

			AND SectionID = @SectionId)





		INSERT INTO SectionPermission (ICENUMBER, SectionID, IsPermitted, CreationDate, ModifyDate) 
		VALUES(@IceNumber, @SectionID, 1, GETUTCDATE(), GETUTCDATE())
END