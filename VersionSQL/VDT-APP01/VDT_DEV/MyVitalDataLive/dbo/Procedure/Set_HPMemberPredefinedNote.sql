/****** Object:  Procedure [dbo].[Set_HPMemberPredefinedNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/25/2011
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Set_HPMemberPredefinedNote]
	@username varchar(50),
	@custID varchar(50),
	@ShortName varchar(50),
	@Note varchar(500),	
	@StatusID varchar(50),
	@resultID int output
AS
BEGIN
	SET NOCOUNT ON;

	if not exists(select ID from HPMemberPredefinedNote where custID = @custID and shortname = @ShortName)
	begin
		insert into HPMemberPredefinedNote(custid,shortname,note,statusID,createdBy,modifiedBy)
		values(@custID,@ShortName,@Note,@StatusID,@username,@username)
		
		set @resultID = 0
	end
	else
	begin
		set @resultID = -1
	end
END