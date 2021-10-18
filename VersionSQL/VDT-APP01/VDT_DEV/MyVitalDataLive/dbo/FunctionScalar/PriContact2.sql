/****** Object:  Function [dbo].[PriContact2]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[PriContact2](@IceNumber varchar(15))
RETURNS varchar(50)
AS
BEGIN
		
	DECLARE @Result varchar(50)
	
	DECLARE ResultCur CURSOR FOR SELECT TOP 2 dbo.FullName(LastName, FirstName, MiddleName) 
	FROM MainCareInfo WHERE ICENUMBER = @IceNumber AND CareTypeID = 2
	
	OPEN ResultCur
	FETCH NEXT FROM ResultCur INTO @Result	
	IF @@FETCH_STATUS = 0
		FETCH NEXT FROM ResultCur INTO @Result	
	IF @@FETCH_STATUS != 0
		SET @Result = ''
	CLOSE ResultCur

	DEALLOCATE ResultCur
	
	RETURN @Result
END