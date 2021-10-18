/****** Object:  Procedure [dbo].[Get_FamilyHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_FamilyHistory] 
	@IceNumber varchar(15),
	@Language BIT = 1
as

	SET NOCOUNT ON
	
	IF(@Language = 1)
		BEGIN -- 1 = english
			SELECT FamilyHistoryID, FamilyHistoryName, CONVERT(bit, 0) AS NA , CONVERT(bit, 0) AS Father,
			CONVERT(bit, 0) AS Mother, CONVERT(bit, 0) AS Sister, CONVERT(bit, 0) AS Brother
			INTO #TmpFamily	
			FROM LookupFamilyHistoryID 
			
			UPDATE #TmpFamily
			SET NA = MFH.NA,
			Father = MFH.Father,
			Mother = MFH.Mother,
			Sister = MFH.Sister,
			Brother = MFH.Brother
			FROM MainFamilyHistory AS MFH WHERE MFH.ICENUMBER = @IceNumber AND
			MFH.FamilyHistoryId = #TmpFamily.FamilyHistoryId	

			SELECT * FROM #TmpFamily

			DROP TABLE #TmpFamily
		END
	ELSE
		BEGIN -- 0 = spanish
			SELECT FamilyHistoryID, FamilyHistoryNameSpanish FamilyHistoryName, CONVERT(bit, 0) AS NA , CONVERT(bit, 0) AS Father,
			CONVERT(bit, 0) AS Mother, CONVERT(bit, 0) AS Sister, CONVERT(bit, 0) AS Brother
			INTO #TmpFamilyEsp	
			FROM LookupFamilyHistoryID 
			
			UPDATE #TmpFamilyEsp
			SET NA = MFH.NA,
			Father = MFH.Father,
			Mother = MFH.Mother,
			Sister = MFH.Sister,
			Brother = MFH.Brother
			FROM MainFamilyHistory AS MFH WHERE MFH.ICENUMBER = @IceNumber AND
			MFH.FamilyHistoryId = #TmpFamilyEsp.FamilyHistoryId	

			SELECT * FROM #TmpFamilyEsp

			DROP TABLE #TmpFamilyEsp
		END