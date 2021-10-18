/****** Object:  Procedure [dbo].[Ems_IsSpecial]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:      Tim Thein
-- Create date: 9/22/2009
-- Description: Returns 1 if email of EMS has special permissions, otherwise 0.
-- =============================================
CREATE PROCEDURE [dbo].[Ems_IsSpecial]
	@Email varchar(50)
AS
BEGIN
	DECLARE @result bit
	SELECT @result = IsSpecial
	FROM MainEMS
	WHERE (Email = @Email) 
	
	SELECT ISNULL(@result, 0)
END