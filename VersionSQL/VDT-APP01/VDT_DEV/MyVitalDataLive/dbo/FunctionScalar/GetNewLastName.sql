/****** Object:  Function [dbo].[GetNewLastName]    Committed by VersionSQL https://www.versionsql.com ******/

create function [dbo].[GetNewLastName](@OldName varchar(50))
returns varchar(50)
as
begin
	declare @lastname varchar(50)
	set @lastname = ''
	
	while (@lastname = '' or @lastname = @OldName or @lastname is null)
	begin
		select @lastname = [Value] FROM dbo.DI_LastName WHERE id = ROUND(382731 * dbo.RANDOM(), 0)
	end
	return @lastname
end