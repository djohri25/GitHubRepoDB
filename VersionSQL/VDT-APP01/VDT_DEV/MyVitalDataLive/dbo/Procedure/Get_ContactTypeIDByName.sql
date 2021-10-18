/****** Object:  Procedure [dbo].[Get_ContactTypeIDByName]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Returns the ID of the contact type identified by @TypeName
*/
CREATE Procedure [dbo].[Get_ContactTypeIDByName] 
	@TypeName varchar(25)
As

Set Nocount On

declare @count int

SELECT @count = count(*)	
FROM LookupCareTypeId 
WHERE CareTypeName = @TypeName

if( @count > 0)
begin
	SELECT  CareTypeId
	FROM LookupCareTypeId 
	WHERE CareTypeName = @TypeName
end
else
begin 
	SELECT -1
end