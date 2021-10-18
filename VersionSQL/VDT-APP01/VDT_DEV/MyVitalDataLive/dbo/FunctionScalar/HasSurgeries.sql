/****** Object:  Function [dbo].[HasSurgeries]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Returns 'Unknown' if data is not permitted to view by medical personnel
	Returns 'Yes' if data is permitted to view and at least one surgery exists in the customer's record
	Returns 'No' if data is permitted to view and no surgeries exist in the customer's record
*/

CREATE FUNCTION [dbo].[HasSurgeries](@MVDID varchar(15))
RETURNS varchar(10)
AS
BEGIN

DECLARE @Result varchar(10)
SET @Result = ''

-- Used to check if the section is permitted to access by Medical personnel
declare @surgerySecID int, @surgeryPermitted bit,@surgeryCount int

-- Get an ID of each section
select @surgerySecID = id from dbo.MainMenuTree where menuname = 'Surgeries'

-- Get permission flag for each section
select @surgeryPermitted=IsPermitted from SectionPermission where sectionID = @surgerySecID and icenumber = @MVDID

if( @surgeryPermitted IS NULL or @surgeryPermitted = '0')
begin
	select @Result = 'Unknown'
end
else
begin
	select @surgeryCount=count(*) from MainSurgeries WHERE ICENUMBER = @MVDID
	if(@surgeryCount > 0)
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