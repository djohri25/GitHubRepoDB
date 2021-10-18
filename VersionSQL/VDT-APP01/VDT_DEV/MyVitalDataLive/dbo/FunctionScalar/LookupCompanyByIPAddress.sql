/****** Object:  Function [dbo].[LookupCompanyByIPAddress]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 7/16/2010
-- Description:	Returns Company Name by looking up IP address
-- =============================================
CREATE FUNCTION [dbo].[LookupCompanyByIPAddress] 
(
	@ipAddress char(15)
)
RETURNS nvarchar(64)
AS
BEGIN
	DECLARE @result nvarchar(64)

	SELECT	@result = CompanyName
	FROM	Companies
	WHERE	@ipAddress BETWEEN IPAddressRangeMin AND IPAddressRangeMax

	RETURN @result
END