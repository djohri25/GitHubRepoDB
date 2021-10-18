/****** Object:  Function [dbo].[GetNewSSN]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[GetNewSSN](@OldSSN varchar(9))
RETURNS varchar(9)
AS
BEGIN
	declare @ssn varchar(9)
	declare @min int
	declare @max int
	set @ssn = ''
	-- SSN - Random nine-digit number
	SELECT @min = 1, @max = 999999999
	while (@ssn = '' or @ssn = @OldSSN)
	begin
		Select @ssn = CAST(CAST(ROUND(((@max) - @min) * dbo.RANDOM() + @min,0) as int)as varchar(9))
	end
	return @ssn
end