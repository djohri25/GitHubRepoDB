/****** Object:  Procedure [dbo].[SET_HEPFormDataControl]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SET_HEPFormDataControl]
	-- Add the parameters for the stored procedure here
	@MVDID varchar(30),
	@Adult_Asthma_OriginalCaseFindDate datetime =NULL,
	@Adult_Asthma_MostRecentCaseFindDate datetime =NULL,
	@Adult_Asthma_MostRecentEnrollDate datetime = NULL,
	@Adult_Asthma_MostRecentCompleteDate datetime = NULL,
	@Adult_Asthma_ExcludeProgram bit = NULL,
	@Adult_Cardio_OriginalCaseFindDate datetime = NULL,
	@Adult_Cardio_MostRecentCaseFindDate datetime = NULL,
	@Adult_Cardio_MostRecentEnrollDate datetime = NULL,
	@Adult_Cardio_MostRecentCompleteDate datetime = NULL,
	@Adult_Cardio_ExcludeProgram bit = NULL,
	@Adult_CHF_OriginalCaseFindDate datetime = NULL,
	@Adult_CHF_MostRecentCaseFindDate datetime = NULL,
	@Adult_CHF_MostRecentEnrollDate datetime = NULL,
	@Adult_CHF_MostRecentCompleteDate datetime = NULL,
	@Adult_CHF_ExcludeProgram bit = NULL,
	@Adult_COPD_OriginalCaseFindDate datetime = NULL,
	@Adult_COPD_MostRecentCaseFindDate datetime = NULL,
	@Adult_COPD_MostRecentEnrollDate datetime = NULL,
	@Adult_COPD_MostRecentCompleteDate datetime = NULL,
	@Adult_COPD_ExcludeProgram bit = NULL,
	@Adult_Diabetes_OriginalCaseFindDate datetime = NULL,
	@Adult_Diabetes_MostRecentCaseFindDate datetime = NULL,
	@Adult_Diabetes_MostRecentEnrollDate datetime = NULL,
	@Adult_Diabetes_MostRecentCompleteDate datetime = NULL,
	@Adult_Diabetes_ExcludeProgram bit = NULL,
	@Adult_Weigh_OriginalCaseFindDate datetime = NULL,
	@Adult_Weigh_MostRecentCaseFindDate datetime = NULL,
	@Adult_Weigh_MostRecentEnrollDate datetime = NULL,
	@Adult_Weigh_MostRecentCompleteDate datetime = NULL,
	@Adult_Weigh_ExcludeProgram bit = NULL,
	@Adult_LBP_OriginalCaseFindDate datetime = NULL,
	@Adult_LBP_MostRecentCaseFindDate datetime = NULL,
	@Adult_LBP_MostRecentEnrollDate datetime = NULL,
	@Adult_LBP_MostRecentCompleteDate datetime = NULL,
	@Adult_LBP_ExcludeProgram bit = NULL,
	@Adult_LBP_ExcludeProgramLowBack bit = NULL,
	@YouthDiabetes_0to3_OriginalCaseFindDate datetime = NULL,
	@YouthDiabetes_0to3_MostRecentCaseFindDate datetime = NULL,
	@YouthDiabetes_0to3_MostRecentEnrollDate datetime = NULL,
	@YouthDiabetes_0to3_MostRecentCompleteDate datetime = NULL,
	@YouthDiabetes_0to3_ExcludeProgram bit = NULL,
	@YouthDiabetes_4to6_OriginalCaseFindDate datetime = NULL,
	@YouthDiabetes_4to6_MostRecentCaseFindDate datetime = NULL,
	@YouthDiabetes_4to6_MostRecentEnrollDate datetime = NULL,
	@YouthDiabetes_4to6_MostRecentCompleteDate datetime = NULL,
	@YouthDiabetes_4to6_ExcludeProgram bit = NULL,
	@YouthDiabetes_7to14_OriginalCaseFindDate datetime = NULL,
	@YouthDiabetes_7to14_MostRecentCaseFindDate datetime = NULL,
	@YouthDiabetes_7to14_MostRecentEnrollDate datetime = NULL,
	@YouthDiabetes_7to14_MostRecentCompleteDate datetime = NULL,
	@YouthDiabetes_7to14_ExcludeProgram bit = NULL,
	@YouthDiabetes_12to17_OriginalCaseFindDate datetime = NULL,
	@YouthDiabetes_12to17_MostRecentCaseFindDate datetime = NULL,
	@YouthDiabetes_12to17_MostRecentEnrollDate datetime = NULL,
	@YouthDiabetes_12to17_MostRecentCompleteDate datetime = NULL,
	@YouthDiabetes_12to17_ExcludeProgram bit = NULL,
	@YouthAsthma_0to3_OriginalCaseFindDate datetime = NULL,
	@YouthAsthma_0to3_MostRecentCaseFindDate datetime = NULL,
	@YouthAsthma_0to3_MostRecentEnrollDate datetime = NULL,
	@YouthAsthma_0to3_MostRecentCompleteDate datetime = NULL,
	@YouthAsthma_0to3_ExcludeProgram bit = NULL,
	@YouthAsthma_4to6_OriginalCaseFindDate datetime = NULL,
	@YouthAsthma_4to6_MostRecentCaseFindDate datetime = NULL,
	@YouthAsthma_4to6_MostRecentEnrollDate datetime = NULL,
	@YouthAsthma_4to6_MostRecentCompleteDate datetime = NULL,
	@YouthAsthma_4to6_ExcludeProgram bit = NULL,
	@YouthAsthma_7to14_OriginalCaseFindDate datetime = NULL,
	@YouthAsthma_7to14_MostRecentCaseFindDate datetime = NULL,
	@YouthAsthma_7to14_MostRecentEnrollDate datetime = NULL,
	@YouthAsthma_7to14_MostRecentCompleteDate datetime = NULL,
	@YouthAsthma_7to14_ExcludeProgram bit = NULL,
	@YouthAsthma_12to17_OriginalCaseFindDate datetime = NULL,
	@YouthAsthma_12to17_MostRecentCaseFindDate datetime = NULL,
	@YouthAsthma_12to17_MostRecentEnrollDate datetime = NULL,
	@YouthAsthma_12to17_MostRecentCompleteDate datetime = NULL,
	@YouthAsthma_12to17_ExcludeProgram bit = NULL,
	@CreatedBy nvarchar(250) = NULL,
	@CreatedDate datetime = NULL,
	@UpdatedBy nvarchar(250) = NULL,
	@UpdatedDate datetime = NULL,
	@Flag int = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @MemberID varchar(15) ;
	select @MemberID from Link_MemberId_MVD_Ins where MVDID = @MVDID;

	IF Exists (select * from HEP_Control where MVDID = @MVDID)
		BEGIN
		if(@Flag = 1) --Update Adult HEP Asthma columns
		BEGIN
			update HEP_Control SET			
			Adult_Asthma_OriginalCaseFindDate = @Adult_Asthma_OriginalCaseFindDate,
			Adult_Asthma_MostRecentCaseFindDate =@Adult_Asthma_MostRecentCaseFindDate ,
			Adult_Asthma_MostRecentEnrollDate =@Adult_Asthma_MostRecentEnrollDate ,
			Adult_Asthma_MostRecentCompleteDate =@Adult_Asthma_MostRecentCompleteDate ,
			Adult_Asthma_ExcludeProgram = @Adult_Asthma_ExcludeProgram ,
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate 
			WHERE MVDID = @MVDID
		END
		if(@Flag = 2) --Update Adult HEP Cardio columns
		BEGIN
			update HEP_Control SET	
			Adult_Cardio_OriginalCaseFindDate =@Adult_Cardio_OriginalCaseFindDate ,
			Adult_Cardio_MostRecentCaseFindDate =@Adult_Cardio_MostRecentCaseFindDate ,
			Adult_Cardio_MostRecentEnrollDate =@Adult_Cardio_MostRecentEnrollDate ,
			Adult_Cardio_MostRecentCompleteDate =@Adult_Cardio_MostRecentCompleteDate ,
			Adult_Cardio_ExcludeProgram =@Adult_Cardio_ExcludeProgram,
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate 
			WHERE MVDID = @MVDID
		END

		if(@Flag = 3) --Update Adult HEP CHF columns
		BEGIN
		update HEP_Control SET	
			Adult_CHF_OriginalCaseFindDate =@Adult_CHF_OriginalCaseFindDate ,
			Adult_CHF_MostRecentCaseFindDate =@Adult_CHF_MostRecentCaseFindDate ,
			Adult_CHF_MostRecentEnrollDate =@Adult_CHF_MostRecentEnrollDate ,
			Adult_CHF_MostRecentCompleteDate =@Adult_CHF_MostRecentCompleteDate ,
			Adult_CHF_ExcludeProgram =@Adult_CHF_ExcludeProgram ,
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate 
			WHERE MVDID = @MVDID
		END

		if(@Flag = 4) --Update Adult HEP COPD columns
		BEGIN
			update HEP_Control SET	
			Adult_COPD_OriginalCaseFindDate =@Adult_COPD_OriginalCaseFindDate ,
			Adult_COPD_MostRecentCaseFindDate =@Adult_COPD_MostRecentCaseFindDate ,
			Adult_COPD_MostRecentEnrollDate =@Adult_COPD_MostRecentEnrollDate ,
			Adult_COPD_MostRecentCompleteDate =@Adult_COPD_MostRecentCompleteDate ,
			Adult_COPD_ExcludeProgram =@Adult_COPD_ExcludeProgram ,
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate 
			WHERE MVDID = @MVDID
		END

		if(@Flag = 5) --Update Adult HEP Diabetes columns
		BEGIN
			update HEP_Control SET	
			Adult_Diabetes_OriginalCaseFindDate =@Adult_Diabetes_OriginalCaseFindDate ,
			Adult_Diabetes_MostRecentCaseFindDate =@Adult_Diabetes_MostRecentCaseFindDate ,
			Adult_Diabetes_MostRecentEnrollDate =@Adult_Diabetes_MostRecentEnrollDate ,
			Adult_Diabetes_MostRecentCompleteDate =@Adult_Diabetes_MostRecentCompleteDate ,
			Adult_Diabetes_ExcludeProgram =@Adult_Diabetes_ExcludeProgram ,
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate 
			WHERE MVDID = @MVDID
		END

		if(@Flag = 6) --Update Adult HEP Weigh columns
		BEGIN
			update HEP_Control SET	
			Adult_Weigh_OriginalCaseFindDate =@Adult_Weigh_OriginalCaseFindDate ,
			Adult_Weigh_MostRecentCaseFindDate =@Adult_Weigh_MostRecentCaseFindDate ,
			Adult_Weigh_MostRecentEnrollDate =@Adult_Weigh_MostRecentEnrollDate ,
			Adult_Weigh_MostRecentCompleteDate =@Adult_Weigh_MostRecentCompleteDate ,
			Adult_Weigh_ExcludeProgram =@Adult_Weigh_ExcludeProgram ,
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate 
			
			WHERE MVDID = @MVDID
		END

		if(@Flag = 7) --Update Adult HEP Low back pain columns
		BEGIN

			update HEP_Control SET
			Adult_LBP_OriginalCaseFindDate =@Adult_LBP_OriginalCaseFindDate ,
			Adult_LBP_MostRecentCaseFindDate =@Adult_LBP_MostRecentCaseFindDate ,
			Adult_LBP_MostRecentEnrollDate =@Adult_LBP_MostRecentEnrollDate ,
			Adult_LBP_MostRecentCompleteDate =@Adult_LBP_MostRecentCompleteDate ,
			Adult_LBP_ExcludeProgram =@Adult_LBP_ExcludeProgram ,
			Adult_LBP_ExcludeProgramLowBack = @Adult_LBP_ExcludeProgramLowBack 	,
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate 
			WHERE MVDID = @MVDID

		END

		if(@Flag = 8) --Update Adult HEP On th level columns
		BEGIN
			update HEP_Control SET
			YouthDiabetes_0to3_OriginalCaseFindDate =@YouthDiabetes_0to3_OriginalCaseFindDate ,
			YouthDiabetes_0to3_MostRecentCaseFindDate =@YouthDiabetes_0to3_MostRecentCaseFindDate ,
			YouthDiabetes_0to3_MostRecentEnrollDate =@YouthDiabetes_0to3_MostRecentEnrollDate ,
			YouthDiabetes_0to3_MostRecentCompleteDate =@YouthDiabetes_0to3_MostRecentCompleteDate ,
			YouthDiabetes_0to3_ExcludeProgram =@YouthDiabetes_0to3_ExcludeProgram ,
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate 
			WHERE MVDID = @MVDID
			
		END
					
		if(@Flag = 9) --Update Adult HEP On th level columns
		BEGIN
			update HEP_Control SET
			YouthDiabetes_4to6_OriginalCaseFindDate =@YouthDiabetes_4to6_OriginalCaseFindDate ,
			YouthDiabetes_4to6_MostRecentCaseFindDate =@YouthDiabetes_4to6_MostRecentCaseFindDate ,
			YouthDiabetes_4to6_MostRecentEnrollDate =@YouthDiabetes_4to6_MostRecentEnrollDate ,
			YouthDiabetes_4to6_MostRecentCompleteDate =@YouthDiabetes_4to6_MostRecentCompleteDate ,
			YouthDiabetes_4to6_ExcludeProgram =@YouthDiabetes_4to6_ExcludeProgram ,
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate 
			WHERE MVDID = @MVDID
			
		END
			
						
		if(@Flag = 10) --Update Adult HEP On th level columns
		BEGIN
			update HEP_Control SET
			YouthDiabetes_7to14_OriginalCaseFindDate =@YouthDiabetes_7to14_OriginalCaseFindDate ,
			YouthDiabetes_7to14_MostRecentCaseFindDate =@YouthDiabetes_7to14_MostRecentCaseFindDate ,
			YouthDiabetes_7to14_MostRecentEnrollDate =@YouthDiabetes_7to14_MostRecentEnrollDate ,
			YouthDiabetes_7to14_MostRecentCompleteDate =@YouthDiabetes_7to14_MostRecentCompleteDate ,
			YouthDiabetes_7to14_ExcludeProgram =@YouthDiabetes_7to14_ExcludeProgram ,
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate 
			WHERE MVDID = @MVDID
			
		END
		
							
		if(@Flag = 11) --Update Adult HEP On the level columns
		BEGIN
			update HEP_Control SET
			YouthDiabetes_12to17_OriginalCaseFindDate =@YouthDiabetes_12to17_OriginalCaseFindDate ,
			YouthDiabetes_12to17_MostRecentCaseFindDate =@YouthDiabetes_12to17_MostRecentCaseFindDate ,
			YouthDiabetes_12to17_MostRecentEnrollDate =@YouthDiabetes_12to17_MostRecentEnrollDate ,
			YouthDiabetes_12to17_MostRecentCompleteDate =@YouthDiabetes_12to17_MostRecentCompleteDate ,
			YouthDiabetes_12to17_ExcludeProgram =@YouthDiabetes_12to17_ExcludeProgram ,
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate 
			WHERE MVDID = @MVDID
			
		END
		
			if(@Flag = 12) --Update Adult HEP Catch AIr columns
		BEGIN
			update HEP_Control SET
			YouthAsthma_0to3_OriginalCaseFindDate =@YouthAsthma_0to3_OriginalCaseFindDate ,
			YouthAsthma_0to3_MostRecentCaseFindDate =@YouthAsthma_0to3_MostRecentCaseFindDate ,
			YouthAsthma_0to3_MostRecentEnrollDate =@YouthAsthma_0to3_MostRecentEnrollDate ,
			YouthAsthma_0to3_MostRecentCompleteDate =@YouthAsthma_0to3_MostRecentCompleteDate ,
			YouthAsthma_0to3_ExcludeProgram =@YouthAsthma_0to3_ExcludeProgram ,
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate 
			WHERE MVDID = @MVDID
			
		END	

			if(@Flag = 13) --Update Adult HEP Catch AIr columns
		BEGIN
			update HEP_Control SET
			YouthAsthma_4to6_OriginalCaseFindDate =@YouthAsthma_4to6_OriginalCaseFindDate ,
			YouthAsthma_4to6_MostRecentCaseFindDate =@YouthAsthma_4to6_MostRecentCaseFindDate ,
			YouthAsthma_4to6_MostRecentEnrollDate =@YouthAsthma_4to6_MostRecentEnrollDate ,
			YouthAsthma_4to6_MostRecentCompleteDate =@YouthAsthma_4to6_MostRecentCompleteDate ,
			YouthAsthma_4to6_ExcludeProgram =@YouthAsthma_4to6_ExcludeProgram,
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate  
			WHERE MVDID = @MVDID
			
		END	

			if(@Flag = 14) --Update Adult HEP Catch AIr columns
		BEGIN
			update HEP_Control SET
			YouthAsthma_7to14_OriginalCaseFindDate =@YouthAsthma_7to14_OriginalCaseFindDate ,
			YouthAsthma_7to14_MostRecentCaseFindDate =@YouthAsthma_7to14_MostRecentCaseFindDate ,
			YouthAsthma_7to14_MostRecentEnrollDate =@YouthAsthma_7to14_MostRecentEnrollDate ,
			YouthAsthma_7to14_MostRecentCompleteDate =@YouthAsthma_7to14_MostRecentCompleteDate ,
			YouthAsthma_7to14_ExcludeProgram =@YouthAsthma_7to14_ExcludeProgram ,
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate 
			WHERE MVDID = @MVDID
			
		END	
		
				if(@Flag = 15) --Update Adult HEP Catch AIr columns
		BEGIN
			update HEP_Control SET
			YouthAsthma_12to17_OriginalCaseFindDate =@YouthAsthma_12to17_OriginalCaseFindDate ,
			YouthAsthma_12to17_MostRecentCaseFindDate =@YouthAsthma_12to17_MostRecentCaseFindDate ,
			YouthAsthma_12to17_MostRecentEnrollDate =@YouthAsthma_12to17_MostRecentEnrollDate ,
			YouthAsthma_12to17_MostRecentCompleteDate =@YouthAsthma_12to17_MostRecentCompleteDate ,
			YouthAsthma_12to17_ExcludeProgram =@YouthAsthma_12to17_ExcludeProgram,			
			UpdatedBy =@UpdatedBy,
			UpdatedDate =@UpdatedDate 

			WHERE MVDID = @MVDID
			
		END	
		if(@Flag =16)
		BEGIN
		Update HEP_Control SET
		Adult_Asthma_ExcludeProgram = @Adult_Asthma_ExcludeProgram,
		Adult_Cardio_ExcludeProgram = @Adult_Cardio_ExcludeProgram,
		Adult_COPD_ExcludeProgram = @Adult_COPD_ExcludeProgram,
		Adult_CHF_ExcludeProgram = @Adult_CHF_ExcludeProgram,
		Adult_Diabetes_ExcludeProgram = @Adult_Diabetes_ExcludeProgram,
		Adult_Weigh_ExcludeProgram = @Adult_Weigh_ExcludeProgram ,
		Adult_LBP_ExcludeProgram =@Adult_LBP_ExcludeProgram ,
		YouthDiabetes_0to3_ExcludeProgram =@YouthDiabetes_0to3_ExcludeProgram ,
		YouthDiabetes_4to6_ExcludeProgram =@YouthDiabetes_4to6_ExcludeProgram ,
		YouthDiabetes_7to14_ExcludeProgram =@YouthDiabetes_7to14_ExcludeProgram ,
		YouthDiabetes_12to17_ExcludeProgram =@YouthDiabetes_12to17_ExcludeProgram ,
		YouthAsthma_0to3_ExcludeProgram =@YouthAsthma_0to3_ExcludeProgram ,
		YouthAsthma_4to6_ExcludeProgram =@YouthAsthma_4to6_ExcludeProgram,
		YouthAsthma_7to14_ExcludeProgram =@YouthAsthma_7to14_ExcludeProgram ,
		YouthAsthma_12to17_ExcludeProgram =@YouthAsthma_12to17_ExcludeProgram,
		updatedBy = @UpdatedBy,
		UpdatedDate = @UpdatedDate

		where MVDID = @MVDID
		END
					
		END

	ELSE 
		BEGIN
			Insert Into HEP_Control 
			(
				MVDID,
				MemberID ,
				Adult_Asthma_OriginalCaseFindDate ,
				Adult_Asthma_MostRecentCaseFindDate,
				Adult_Asthma_MostRecentEnrollDate ,
				Adult_Asthma_MostRecentCompleteDate,
				Adult_Asthma_ExcludeProgram ,
				Adult_Cardio_OriginalCaseFindDate ,
				Adult_Cardio_MostRecentCaseFindDate,
				Adult_Cardio_MostRecentEnrollDate ,
				Adult_Cardio_MostRecentCompleteDate ,
				Adult_Cardio_ExcludeProgram ,
				Adult_CHF_OriginalCaseFindDate,
				Adult_CHF_MostRecentCaseFindDate ,
				Adult_CHF_MostRecentEnrollDate ,
				Adult_CHF_MostRecentCompleteDate,
				Adult_CHF_ExcludeProgram ,
				Adult_COPD_OriginalCaseFindDate ,
				Adult_COPD_MostRecentCaseFindDate,
				Adult_COPD_MostRecentEnrollDate ,
				Adult_COPD_MostRecentCompleteDate ,
				Adult_COPD_ExcludeProgram ,
				Adult_Diabetes_OriginalCaseFindDate ,
				Adult_Diabetes_MostRecentCaseFindDate ,
				Adult_Diabetes_MostRecentEnrollDate ,
				Adult_Diabetes_MostRecentCompleteDate ,
				Adult_Diabetes_ExcludeProgram ,
				Adult_Weigh_OriginalCaseFindDate ,
				Adult_Weigh_MostRecentCaseFindDate ,
				Adult_Weigh_MostRecentEnrollDate ,
				Adult_Weigh_MostRecentCompleteDate ,
				Adult_Weigh_ExcludeProgram ,
				Adult_LBP_OriginalCaseFindDate ,
				Adult_LBP_MostRecentCaseFindDate ,
				Adult_LBP_MostRecentEnrollDate ,
				Adult_LBP_MostRecentCompleteDate ,
				Adult_LBP_ExcludeProgram ,
				Adult_LBP_ExcludeProgramLowBack ,
				YouthDiabetes_0to3_OriginalCaseFindDate ,
				YouthDiabetes_0to3_MostRecentCaseFindDate ,
				YouthDiabetes_0to3_MostRecentEnrollDate ,
				YouthDiabetes_0to3_MostRecentCompleteDate ,
				YouthDiabetes_0to3_ExcludeProgram ,
				YouthDiabetes_4to6_OriginalCaseFindDate ,
				YouthDiabetes_4to6_MostRecentCaseFindDate ,
				YouthDiabetes_4to6_MostRecentEnrollDate ,
				YouthDiabetes_4to6_MostRecentCompleteDate ,
				YouthDiabetes_4to6_ExcludeProgram ,
				YouthDiabetes_7to14_OriginalCaseFindDate ,
				YouthDiabetes_7to14_MostRecentCaseFindDate ,
				YouthDiabetes_7to14_MostRecentEnrollDate ,
				YouthDiabetes_7to14_MostRecentCompleteDate ,
				YouthDiabetes_7to14_ExcludeProgram ,
				YouthDiabetes_12to17_OriginalCaseFindDate ,
				YouthDiabetes_12to17_MostRecentCaseFindDate ,
				YouthDiabetes_12to17_MostRecentEnrollDate ,
				YouthDiabetes_12to17_MostRecentCompleteDate ,
				YouthDiabetes_12to17_ExcludeProgram ,
				YouthAsthma_0to3_OriginalCaseFindDate ,
				YouthAsthma_0to3_MostRecentCaseFindDate ,
				YouthAsthma_0to3_MostRecentEnrollDate ,
				YouthAsthma_0to3_MostRecentCompleteDate ,
				YouthAsthma_0to3_ExcludeProgram ,
				YouthAsthma_4to6_OriginalCaseFindDate ,
				YouthAsthma_4to6_MostRecentCaseFindDate ,
				YouthAsthma_4to6_MostRecentEnrollDate ,
				YouthAsthma_4to6_MostRecentCompleteDate ,
				YouthAsthma_4to6_ExcludeProgram ,
				YouthAsthma_7to14_OriginalCaseFindDate ,
				YouthAsthma_7to14_MostRecentCaseFindDate ,
				YouthAsthma_7to14_MostRecentEnrollDate ,
				YouthAsthma_7to14_MostRecentCompleteDate ,
				YouthAsthma_7to14_ExcludeProgram ,
				YouthAsthma_12to17_OriginalCaseFindDate ,
				YouthAsthma_12to17_MostRecentCaseFindDate ,
				YouthAsthma_12to17_MostRecentEnrollDate ,
				YouthAsthma_12to17_MostRecentCompleteDate ,
				YouthAsthma_12to17_ExcludeProgram ,
				CreatedBy ,
				CreatedDate 
			)
		Values  
		(
				@MVDID,
				@MemberID ,
				@Adult_Asthma_OriginalCaseFindDate ,
				@Adult_Asthma_MostRecentCaseFindDate,
				@Adult_Asthma_MostRecentEnrollDate ,
				@Adult_Asthma_MostRecentCompleteDate,
				@Adult_Asthma_ExcludeProgram ,
				@Adult_Cardio_OriginalCaseFindDate ,
				@Adult_Cardio_MostRecentCaseFindDate,
				@Adult_Cardio_MostRecentEnrollDate ,
				@Adult_Cardio_MostRecentCompleteDate ,
				@Adult_Cardio_ExcludeProgram ,
				@Adult_CHF_OriginalCaseFindDate,
				@Adult_CHF_MostRecentCaseFindDate ,
				@Adult_CHF_MostRecentEnrollDate ,
				@Adult_CHF_MostRecentCompleteDate,
				@Adult_CHF_ExcludeProgram ,
				@Adult_COPD_OriginalCaseFindDate ,
				@Adult_COPD_MostRecentCaseFindDate,
				@Adult_COPD_MostRecentEnrollDate ,
				@Adult_COPD_MostRecentCompleteDate ,
				@Adult_COPD_ExcludeProgram ,
				@Adult_Diabetes_OriginalCaseFindDate ,
				@Adult_Diabetes_MostRecentCaseFindDate ,
				@Adult_Diabetes_MostRecentEnrollDate ,
				@Adult_Diabetes_MostRecentCompleteDate ,
				@Adult_Diabetes_ExcludeProgram ,
				@Adult_Weigh_OriginalCaseFindDate ,
				@Adult_Weigh_MostRecentCaseFindDate ,
				@Adult_Weigh_MostRecentEnrollDate ,
				@Adult_Weigh_MostRecentCompleteDate ,
				@Adult_Weigh_ExcludeProgram ,
				@Adult_LBP_OriginalCaseFindDate ,
				@Adult_LBP_MostRecentCaseFindDate ,
				@Adult_LBP_MostRecentEnrollDate ,
				@Adult_LBP_MostRecentCompleteDate ,
				@Adult_LBP_ExcludeProgram ,
				@Adult_LBP_ExcludeProgramLowBack ,
				@YouthDiabetes_0to3_OriginalCaseFindDate ,
				@YouthDiabetes_0to3_MostRecentCaseFindDate ,
				@YouthDiabetes_0to3_MostRecentEnrollDate ,
				@YouthDiabetes_0to3_MostRecentCompleteDate ,
				@YouthDiabetes_0to3_ExcludeProgram ,
				@YouthDiabetes_4to6_OriginalCaseFindDate ,
				@YouthDiabetes_4to6_MostRecentCaseFindDate ,
				@YouthDiabetes_4to6_MostRecentEnrollDate ,
				@YouthDiabetes_4to6_MostRecentCompleteDate ,
				@YouthDiabetes_4to6_ExcludeProgram ,
				@YouthDiabetes_7to14_OriginalCaseFindDate ,
				@YouthDiabetes_7to14_MostRecentCaseFindDate ,
				@YouthDiabetes_7to14_MostRecentEnrollDate ,
				@YouthDiabetes_7to14_MostRecentCompleteDate ,
				@YouthDiabetes_7to14_ExcludeProgram ,
				@YouthDiabetes_12to17_OriginalCaseFindDate ,
				@YouthDiabetes_12to17_MostRecentCaseFindDate ,
				@YouthDiabetes_12to17_MostRecentEnrollDate ,
				@YouthDiabetes_12to17_MostRecentCompleteDate ,
				@YouthDiabetes_12to17_ExcludeProgram ,
				@YouthAsthma_0to3_OriginalCaseFindDate ,
				@YouthAsthma_0to3_MostRecentCaseFindDate ,
				@YouthAsthma_0to3_MostRecentEnrollDate ,
				@YouthAsthma_0to3_MostRecentCompleteDate ,
				@YouthAsthma_0to3_ExcludeProgram ,
				@YouthAsthma_4to6_OriginalCaseFindDate ,
				@YouthAsthma_4to6_MostRecentCaseFindDate ,
				@YouthAsthma_4to6_MostRecentEnrollDate ,
				@YouthAsthma_4to6_MostRecentCompleteDate ,
				@YouthAsthma_4to6_ExcludeProgram ,
				@YouthAsthma_7to14_OriginalCaseFindDate ,
				@YouthAsthma_7to14_MostRecentCaseFindDate ,
				@YouthAsthma_7to14_MostRecentEnrollDate ,
				@YouthAsthma_7to14_MostRecentCompleteDate ,
				@YouthAsthma_7to14_ExcludeProgram ,
				@YouthAsthma_12to17_OriginalCaseFindDate ,
				@YouthAsthma_12to17_MostRecentCaseFindDate ,
				@YouthAsthma_12to17_MostRecentEnrollDate ,
				@YouthAsthma_12to17_MostRecentCompleteDate ,
				@YouthAsthma_12to17_ExcludeProgram ,
				@CreatedBy ,
				@CreatedDate 
		)
		END

    -- Insert statements for procedure here

END