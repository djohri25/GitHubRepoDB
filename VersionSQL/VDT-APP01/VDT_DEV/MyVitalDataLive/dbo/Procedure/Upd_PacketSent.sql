/****** Object:  Procedure [dbo].[Upd_PacketSent]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Set the isPackageSent flag for specific customer. The flag indicates that
	the welcome packet was sent to the customer. If the record doesn't exist
	then create.
*/
CREATE Procedure [dbo].[Upd_PacketSent]
	@MVDID varchar(50)
As

SET NOCOUNT ON
	declare @count int
	set @count = 0
	select @count=count(*) from UserAdditionalInfo where MVDID = @MVDID

	if( @count = 0)
	begin
		insert into UserAdditionalInfo (mvdid,ispackagesent,lastupdate)
		values(@MVDID,'1',getutcdate())
	end
	else
	begin
		UPDATE UserAdditionalInfo SET ispackagesent = '1',lastupdate=getutcdate() WHERE mvdid = @MVDID
	end
	