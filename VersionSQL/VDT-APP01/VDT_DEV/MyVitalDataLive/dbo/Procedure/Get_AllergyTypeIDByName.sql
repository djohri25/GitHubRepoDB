/****** Object:  Procedure [dbo].[Get_AllergyTypeIDByName]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Returns the ID of the allergy type identified by @TypeName
*/
CREATE Procedure [dbo].[Get_AllergyTypeIDByName] 
	@TypeName varchar(25)
As

Set Nocount On

declare @count int

SELECT @count = count(*)	
FROM LookupAllergies 
WHERE AllergenTypeName = @TypeName

if( @count > 0)
begin
	SELECT  AllergenTypeId
	FROM LookupAllergies 
	WHERE AllergenTypeName = @TypeName
end
else
begin 
	SELECT -1
end