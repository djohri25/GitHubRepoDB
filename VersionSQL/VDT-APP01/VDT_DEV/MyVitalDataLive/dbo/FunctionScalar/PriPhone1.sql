/****** Object:  Function [dbo].[PriPhone1]    Committed by VersionSQL https://www.versionsql.com ******/

create FUNCTION [dbo].[PriPhone1](@IceNumber varchar(15))
RETURNS varchar(50)
AS
BEGIN

	
	DECLARE @Result varchar(50)
	
	SELECT TOP 1 @Result = dbo.FormatPhone(PhoneHome) FROM MainCareInfo WHERE ICENUMBER = @IceNumber
	AND CareTypeID = 2

	RETURN @Result
END