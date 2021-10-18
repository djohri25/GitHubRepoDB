/****** Object:  Function [dbo].[HasMedications]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Returns 'Unknown' if data is not permitted to view by medical personnel
	Returns 'Yes' if data is permitted to view and at least one medication exists in the customer's record
	Returns 'No' if data is permitted to view and no medications exist in the customer's record
*/

CREATE FUNCTION [dbo].[HasMedications](@MVDID varchar(15))
RETURNS varchar(10)
AS
BEGIN

DECLARE @Result varchar(10)
SET @Result = ''

-- Used to check if the section is permitted to access by Medical personnel
declare @medicationSecID int, @medicationPermitted bit,@medicationCount int

-- Get an ID of each section
select @medicationSecID = id from dbo.MainMenuTree where menuname = 'Medication'

-- Get permission flag for each section
select @medicationPermitted=IsPermitted from SectionPermission where sectionID = @medicationSecID and icenumber = @MVDID

if( @medicationPermitted IS NULL or @medicationPermitted = '0')
begin
	select @Result = 'Unknown'
end
else
begin
	select @medicationCount=count(*) from MainMedication WHERE ICENUMBER = @MVDID
	if(@medicationCount > 0)
	begin
		select @Result = 'Yes'
	end
	else
	begin
		select @Result = 'No'
	end
end

	RETURN @Result
END