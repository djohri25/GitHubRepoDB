/****** Object:  Function [dbo].[GetNewDOB]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE function [dbo].[GetNewDOB](@OldDOB DateTime)
returns SmallDateTime
as
begin
	declare @dob datetime
	declare @min int
	declare @max int
	declare @pm int
	declare @rr decimal(10,10)
	select @rr = dbo.Random()
	set @pm = ROUND(((10) - 0) * @rr + 0,0)
	if @pm > 5
		set @pm = 1 
	else 
		set @pm = -1
	set @dob = dateadd(day,-22,@OldDOB)
	SELECT @min = 1, @max = 53
	while (@dob = dateadd(day,-22,@OldDOB) or @dob = @OldDOB)
	begin
		Select @dob = DateAdd(day,(CAST(ROUND((@max - @min) * dbo.RANDOM() + @min,0) as int) * @pm), @OldDOB)
	end
	return @dob
end