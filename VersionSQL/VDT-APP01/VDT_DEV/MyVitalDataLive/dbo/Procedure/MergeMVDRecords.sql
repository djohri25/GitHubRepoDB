/****** Object:  Procedure [dbo].[MergeMVDRecords]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/28/2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[MergeMVDRecords]
	@MVDID_1 varchar(20),
	@MVDID_2 varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	declare @NewMVDID varchar(20)
	
	BEGIN TRY
		BEGIN TRANSACTION
	
		EXEC Merge_PersonalDetails
			@MVDID_1 = @MVDID_1,
			@MVDID_2 = @MVDID_2	

		EXEC Merge_Medications
			@MVDID_1 = @MVDID_1,
			@MVDID_2 = @MVDID_2				

		EXEC Merge_Insurance
			@MVDID_1 = @MVDID_1,
			@MVDID_2 = @MVDID_2				

		EXEC Merge_Condition
			@MVDID_1 = @MVDID_1,
			@MVDID_2 = @MVDID_2				

		EXEC Merge_CareInfo
			@MVDID_1 = @MVDID_1,
			@MVDID_2 = @MVDID_2		
			
		EXEC Merge_Surgeries
			@MVDID_1 = @MVDID_1,
			@MVDID_2 = @MVDID_2										

		EXEC Merge_Place
			@MVDID_1 = @MVDID_1,
			@MVDID_2 = @MVDID_2										

		EXEC Merge_Specialist
			@MVDID_1 = @MVDID_1,
			@MVDID_2 = @MVDID_2										

		EXEC Merge_LabData
			@MVDID_1 = @MVDID_1,
			@MVDID_2 = @MVDID_2										

		EXEC Merge_diseaseManagement
			@MVDID_1 = @MVDID_1,
			@MVDID_2 = @MVDID_2										

		EXEC Merge_EDVisit
			@MVDID_1 = @MVDID_1,
			@MVDID_2 = @MVDID_2										
	
		update MD_Alert set MVDID = @MVDID_1
		where MVDID = @MVDID_2
	
		update MD_Note set MVDID = @MVDID_1
		where MVDID = @MVDID_2
	
		update MVD_AppRecord set MVDID = @MVDID_1
		where MVDID = @MVDID_2

		update MVD_AppRecord_MD set MVDID = @MVDID_1
		where MVDID = @MVDID_2

		insert into Link_HPMember_Doctor(MVDID,Doctor_Id,DoctorFirstName,DoctorLastName,Created)
		select @MVDID_1,Doctor_Id,DoctorFirstName,DoctorLastName,Created 
		from Link_HPMember_Doctor
		where MVDID = @MVDID_2 and  
			Doctor_Id NOT IN
			(
				select Doctor_Id from Link_HPMember_Doctor where MVDID = @MVDID_1
			)				
			
		insert into Link_DuplicateRecords(MVDID_1,MVDID_2,Status, MergedRecordMVDID) 
		values(@MVDID_1,@MVDID_2,'MERGE',@MVDID_1)

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		
	END CATCH
	
END