/****** Object:  Function [dbo].[GetNewFirstName]    Committed by VersionSQL https://www.versionsql.com ******/

create function [dbo].[GetNewFirstName](@OldName varchar(50), @GenderID int)
returns varchar(50)
as
begin
	declare @firstname varchar(50)
	set @firstname = ''
	declare @gender as varchar(5)
	if (@GenderID = 1) 
		set @gender = 'M' 
	else 
		set @gender = 'F'
	
	while (@firstname = '' or @firstname = @OldName or @firstname is null)
	begin
		select @firstname = [Value] FROM dbo.DI_FirstName WHERE id = ROUND(341612 * dbo.RANDOM(), 0) and Gender = @gender
	end
	return @firstname
end