/****** Object:  Procedure [dbo].[Delete_AccountWithIceGroup]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Delete_AccountWithIceGroup] 

AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @IceGroup varchar(15), @IceNum varchar(15)
	
	SET @IceGroup = 'Y59SD82PZ3'

	DELETE FROM MainUserName WHERE ICEGROUP = @IceGroup
		
	DECLARE IceNum CURSOR FOR SELECT ICENUMBER FROM MainICENUMBERGroups
	WHERE ICEGROUP = @IceGroup
	
	OPEN IceNum
	
	FETCH NEXT FROM IceNum INTO @IceNum
	
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		EXEC Delete_RecordsWithIceNumber @IceNum
		FETCH NEXT FROM IceNum INTO @IceNum
	END
	
	CLOSE IceNum

	DEALLOCATE IceNum
	
	DELETE FROM MainICENUMBERGroups WHERE ICEGROUP = @IceGroup
	
	DELETE FROM MainICEGROUP WHERE ICEGROUP = @IceGroup
END