/****** Object:  Function [dbo].[GetNewZip]    Committed by VersionSQL https://www.versionsql.com ******/

create function [dbo].[GetNewZip](@OldZip varchar(9))
returns varchar(9)
as
begin
	declare @zip varchar(9)
	declare @min int
	declare @max int
	set @zip = ''

	SELECT @min = 1, @max = 99999
	while (@zip = '' or @zip = @OldZip)
	begin
		Select @zip = CAST(CAST(ROUND(((@max) - @min) * dbo.RANDOM() + @min,0) as int)as varchar(5))
	end
	return @zip
end