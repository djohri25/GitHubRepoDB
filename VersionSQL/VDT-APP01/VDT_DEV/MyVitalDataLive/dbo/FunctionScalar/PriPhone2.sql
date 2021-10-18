/****** Object:  Function [dbo].[PriPhone2]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[PriPhone2](@IceNumber varchar(15))
RETURNS varchar(50)
AS
BEGIN
		
	DECLARE @Result varchar(50)
	
	DECLARE ResultCur CURSOR FOR SELECT TOP 2 PhoneHome 
	FROM MainCareInfo WHERE ICENUMBER = @IceNumber AND CareTypeID = 2
	
	OPEN ResultCur
	FETCH NEXT FROM ResultCur INTO @Result	
	IF @@FETCH_STATUS = 0
		FETCH NEXT FROM ResultCur INTO @Result	
	IF @@FETCH_STATUS != 0
		SET @Result = ''
	CLOSE ResultCur

	DEALLOCATE ResultCur
	
	RETURN dbo.FormatPhone(@Result)
END