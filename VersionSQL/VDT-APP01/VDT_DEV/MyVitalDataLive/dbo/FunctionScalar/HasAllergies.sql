/****** Object:  Function [dbo].[HasAllergies]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Returns 'Unknown' if data is not permitted to view by medical personnel
	Returns 'Yes' if data is permitted to view and at least one allergy exists in the customer's record
	Returns 'No' if data is permitted to view and no allergies exist in the customer's record
*/

CREATE FUNCTION [dbo].[HasAllergies](@MVDID varchar(15))
RETURNS varchar(10)
AS
BEGIN

DECLARE @Result varchar(10)
SET @Result = ''

-- Used to check if the section is permitted to access by Medical personnel
declare @allergiesSecID int, @allergiesPermitted bit,@allergiesCount int

-- Get an ID of each section
select @allergiesSecID = id from dbo.MainMenuTree where menuname = 'Allergies'

-- Get permission flag for each section
select @allergiesPermitted=IsPermitted from SectionPermission where sectionID = @allergiesSecID and icenumber = @MVDID

if( @allergiesPermitted IS NULL or @allergiesPermitted = '0')
begin
	select @Result = 'Unknown'
end
else
begin
	select @allergiesCount=count(*) from MainAllergies WHERE ICENUMBER = @MVDID
	if(@allergiesCount > 0)
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