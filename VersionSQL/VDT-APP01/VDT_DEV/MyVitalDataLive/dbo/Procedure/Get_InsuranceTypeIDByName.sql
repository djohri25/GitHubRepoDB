/****** Object:  Procedure [dbo].[Get_InsuranceTypeIDByName]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Returns the ID of the insurance type identified by @TypeName
*/
CREATE Procedure [dbo].[Get_InsuranceTypeIDByName] 
	@TypeName varchar(50)
As

Set Nocount On

declare @count int

if(@TypeName = 'Primary Health Insurance')
begin
	-- The database name was changed to 'Primary Health' so make an adjustment
	set @TypeName = 'Primary Health'
end

SELECT @count = count(*)	
FROM LookupInsuranceTypeID 
WHERE InsuranceTypeName = @TypeName

if( @count > 0)
begin
	SELECT  InsuranceTypeId
	FROM LookupInsuranceTypeID 
	WHERE InsuranceTypeName = @TypeName
end
else
begin 
	SELECT -1
end