/****** Object:  Procedure [dbo].[uspGetFormStatus]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[uspGetFormStatus]
(
	
	@MVDID varchar(30),
	@CustID int,
	@FormName varchar(128),
	@IsFormActive bit= 1 OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

	IF (@FormName = 'ABCBS_Bariatric')
	    BEGIN
		 if exists ( select * from ABCBS_Bariatric_Form where SectionCompleted = 0 and qCompletedProgram = 'No' and MVDID = @MVDID)
			BEGIN
				SET @IsFormActive = 0;
			END
			
		if not exists ( select * from ABCBS_Bariatric_Form where SectionCompleted = 0 and qCompletedProgram = 'No' and MVDID = @MVDID)
			BEGIN
			 SET @IsFormActive = 1;
			END
	
	END
	
	ELSE if (@FormName = 'ABCBS_SWOutReachAndResource')
		BEGIN
			 if exists ( select * from ABCBS_SWOutReachAndResource_Form where SectionCompleted = 0 and qLockForm = 'No' and MVDID = @MVDID)
				BEGIN
					SET @IsFormActive = 0;
				END
			
			if not exists ( select * from ABCBS_SWOutReachAndResource_Form where SectionCompleted = 0 and qLockForm = 'No' and MVDID = @MVDID)
				BEGIN
					SET @IsFormActive = 1;
				END
		END
	ELSE
		BEGIN
			SET @IsFormActive = 1;
		END
END;