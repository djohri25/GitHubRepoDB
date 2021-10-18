/****** Object:  Procedure [dbo].[Delete_RecordIceGroup]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Del_RecordIceGroup] 

AS
BEGIN
	
	SET NOCOUNT ON;

    DELETE MainICENUMBERGroups WHERE ICENUMBER NOT IN 
	(SELECT	ICENUMBER FROM MainPersonalDetails)
	
	DELETE MainICEGROUP WHERE ICEGROUP NOT IN
	(SELECT DISTINCT ICEGROUP FROM MainICENUMBERGroups)
END