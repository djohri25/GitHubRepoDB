/****** Object:  Function [dbo].[FormatAddress]    Committed by VersionSQL https://www.versionsql.com ******/

create FUNCTION [dbo].[FormatAddress](@Address1 varchar(50), @Address2 varchar(50), @City varchar(50), @State varchar(50), @Zip varchar(20))
RETURNS varchar(500)
AS
BEGIN
	DECLARE @FullAddress varchar(500)
	
	SET @FullAddress = ISNULL(@Address1, '') + ISNULL(' ' + @Address2, '') + ISNULL(', ' + @City, '') + ISNULL(', ' + @State, '') + ISNULL(' ' + @Zip, '') 

	RETURN @FullAddress
END