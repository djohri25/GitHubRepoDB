/****** Object:  Procedure [dbo].[Get_SelectedFamilyHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_SelectedFamilyHistory]
	@ICENUMBER varchar(15)
AS

SELECT LFH.FamilyHistoryID, LFH.FamilyHistoryName,MFH.NA, MFH.Father, MFH.Mother, MFH.Sister,MFH.Brother
	FROM LookupFamilyHistoryID LFH INNER JOIN
	MainFamilyHistory AS MFH ON
LFH.FamilyHistoryID = MFH.FamilyHistoryID
WHERE MFH.ICENUMBER = @ICENUMBER 
AND (MFH.NA != 0 OR MFH.Father != 0 OR MFH.Mother != 0 
		OR MFH.Sister != 0 OR MFH.Brother != 0)