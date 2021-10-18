/****** Object:  Procedure [dbo].[Get_CareTypeList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_CareTypeList]
	@Language BIT = 1
AS

SET NOCOUNT ON
IF (@Language = 1)
	-- 1 = english
	SELECT CareTypeID, CareTypeName FROM LookupCareTypeId ORDER BY CareTypeID

ELSE
	-- 0 = spanish
	SELECT CareTypeID, CareTypeNameSpanish CareTypeName FROM LookupCareTypeId ORDER BY CareTypeID