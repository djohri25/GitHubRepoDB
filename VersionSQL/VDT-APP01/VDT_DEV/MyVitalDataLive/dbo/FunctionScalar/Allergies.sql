/****** Object:  Function [dbo].[Allergies]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[Allergies](@IceNumber varchar(15))
RETURNS varchar(100)
AS
BEGIN
	IF dbo.HasAllergies(@IceNumber) <> 'Yes'
		RETURN ''
		
	DECLARE @Result varchar(100), @Temp varchar(25)
	SET @Result = ''
		
	DECLARE ResultCur CURSOR FOR
	SELECT AllergenName FROM MainAllergies WHERE
	ICENUMBER = @IceNumber

	OPEN ResultCur
	FETCH NEXT FROM ResultCur INTO @Temp
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF LEN(@Result) = 0
			SET @Result = @Temp
		ELSE
			SET @Result = @Result + ', ' + @Temp
	
		FETCH NEXT FROM ResultCur INTO @Temp
	END

	CLOSE ResultCur
	DEALLOCATE ResultCur

	RETURN @Result
END