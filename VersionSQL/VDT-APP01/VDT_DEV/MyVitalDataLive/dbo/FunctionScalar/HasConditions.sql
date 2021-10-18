/****** Object:  Function [dbo].[HasConditions]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Returns 'Unknown' if data is not permitted to view by medical personnel
	Returns 'Yes' if data is permitted to view and at least one condition exists in the customer's record
	Returns 'No' if data is permitted to view and no conditions exist in the customer's record
*/

CREATE FUNCTION [dbo].[HasConditions](@MVDID varchar(15))
RETURNS varchar(10)
AS
BEGIN

DECLARE @Result varchar(10)
SET @Result = ''

-- Used to check if the section is permitted to access by Medical personnel
declare @conditionsSecID int, @conditionsPermitted bit,@conditionsCount int

-- Get an ID of each section
select @conditionsSecID = id from dbo.MainMenuTree where menuname = 'Diseases/Conditions'

-- Get permission flag for each section
select @conditionsPermitted=IsPermitted from SectionPermission where sectionID = @conditionsSecID and icenumber = @MVDID

if( @conditionsPermitted IS NULL or @conditionsPermitted = '0')
begin
	select @Result = 'Unknown'
end
else
begin
	select @conditionsCount=count(*) from MainCondition WHERE ICENUMBER = @MVDID
	if(@conditionsCount > 0)
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