/****** Object:  Function [dbo].[GetNewPhone]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE function [dbo].[GetNewPhone](@OldPhone varchar(14))
returns varchar(14)
as
begin
	declare @phone varchar(14)
	declare @min int
	declare @max int
	set @phone = ''

	SELECT @min = 1111, @max = 9999
	while (@phone = '' or @phone = @OldPhone)
	begin	
		Select @phone = --'(' + 
						CAST(CAST(ROUND(((999) - 111) * dbo.RANDOM() + 111,0) as int)as varchar(3)) + --') ' +
							  CAST(CAST(ROUND(((999) - 111) * dbo.RANDOM() + 111,0) as int)as varchar(3))	+ --'-' +
							  CAST(CAST(ROUND(((@max) - @min) * dbo.RANDOM() + @min,0) as int)as varchar(4))
	end
	return @phone
end