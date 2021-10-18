/****** Object:  Procedure [dbo].[Get_WebSerivceLog]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_WebSerivceLog]
As


SET NOCOUNT ON
	SELECT RecordNumber, ServiceName, ClientIP, CreationDate FROM WebserviceLog
	ORDER BY CreationDate