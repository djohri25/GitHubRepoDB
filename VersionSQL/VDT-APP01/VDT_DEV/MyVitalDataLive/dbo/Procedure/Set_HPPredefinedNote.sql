/****** Object:  Procedure [dbo].[Set_HPPredefinedNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/25/2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_HPPredefinedNote]
	@username varchar(50),
	@custID varchar(50),
	@ShortName varchar(50),
	@Note varchar(max),
	@StatusID varchar(50),
	@AlertGroupID varchar(50) = null,	
	@resultID int output
AS
BEGIN
	SET NOCOUNT ON;

	if not exists(select ID from HPAlertPredefinedNote where custID = @custID and shortname = @ShortName)
	begin
		insert into HPAlertPredefinedNote(custid,shortname,note,statusID,createdBy,modifiedBy,AlertGroupID)
		values(@custID,@ShortName,@Note,@statusID,@username,@username,@AlertGroupID)
		
		set @resultID = 0
	end
	else
	begin
		set @resultID = -1
	end
END