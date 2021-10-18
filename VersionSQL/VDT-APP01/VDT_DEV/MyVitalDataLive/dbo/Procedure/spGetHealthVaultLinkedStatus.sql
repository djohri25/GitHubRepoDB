/****** Object:  Procedure [dbo].[spGetHealthVaultLinkedStatus]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE
Procedure [dbo].[spGetHealthVaultLinkedStatus]  
@ICENUMBER varchar(15)
as
set nocount on

BEGIN
	SELECT 
			CASE 
				WHEN HVUserID IS NULL THEN 0
				WHEN HVUserID = '00000000-0000-0000-0000-000000000000' THEN 0 -- Empty GUID
				WHEN HVUserID IS NOT NULL THEN 1  
				ELSE 0 
			END 
		Result FROM dbo.MainICENUMBERGroups WHERE ICENUMBER = @ICENUMBER
END