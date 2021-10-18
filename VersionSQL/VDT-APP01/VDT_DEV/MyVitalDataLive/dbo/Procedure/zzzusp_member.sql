/****** Object:  Procedure [dbo].[zzzusp_member]    Committed by VersionSQL https://www.versionsql.com ******/

create procedure zzzusp_member
(@id int output)
as
begin

declare @v_id int = 5 

select @id = @v_id
select @id

end