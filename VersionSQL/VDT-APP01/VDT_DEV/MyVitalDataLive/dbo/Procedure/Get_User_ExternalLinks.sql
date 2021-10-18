/****** Object:  Procedure [dbo].[Get_User_ExternalLinks]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROC [dbo].[Get_User_ExternalLinks] (@pCustID int = NULL)
AS
/*
	Get user defined external links for Affinite' application

Changes:
WHO		WHEN		WHAT
Scott	2021-03-08	Created

EXEC Get_User_ExternalLinks 10
*/
BEGIN

DECLARE @CustID int = @pCustID

SELECT	el.CustID
		,el.SortOrder
		,el.LinkTarget
		,el.LinkLabel
		,el.LinkHRef
		,el.LinkImage
		,el.LinkIcon
		,el.InAppAction
		,el.AppObserverService
		,el.ObserverFunc
		,el.EventName
		,el.DataToPass  
FROM	dbo.User_ExternalLinks el
WHERE	CustID = COALESCE(@CustID, CustID)
ORDER BY SortOrder

END