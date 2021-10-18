/****** Object:  Function [dbo].[GetFullName]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[GetFullName]
	(
	@userName nvarchar(256) 
	)
RETURNS nvarchar (102)
AS
BEGIN
	IF db_name() = 'MyVitalDataDev'
		SET @userName = MVDSupportDev.dbo.GetFullName(@userName)
	ELSE IF db_name() = 'MyVitalDataTest1'
		SET @userName = MVDSupportTest1.dbo.GetFullName(@userName)
	ELSE IF db_name() = 'MyVitalDataTest2'
		SET @userName = MVDSupportTest2.dbo.GetFullName(@userName)
	ELSE IF db_name() = 'MyVitalDataDemo'
		SET @userName = MVDSupportDemo.dbo.GetFullName(@userName)
	ELSE IF db_name() = 'MyVitalDataLive'
		SET @userName = MVDSupportLive.dbo.GetFullName(@userName)
	ELSE IF db_name() = 'MyVitalDataUAT'
		SET @userName = MVDSupportUAT.dbo.GetFullName(@userName)
		
	RETURN @userName
END