/****** Object:  Function [dbo].[PriPhyPhone]    Committed by VersionSQL https://www.versionsql.com ******/

create FUNCTION [dbo].[PriPhyPhone](@IceNumber varchar(15))
	RETURNS varchar(15)
AS
BEGIN
		
	DECLARE @Result varchar(15)
	
	SELECT TOP 1 @Result = dbo.FormatPhone(Phone) FROM MainSpecialist 
	WHERE ICENUMBER = @IceNumber AND RoleID = 1
	
	RETURN @Result
END