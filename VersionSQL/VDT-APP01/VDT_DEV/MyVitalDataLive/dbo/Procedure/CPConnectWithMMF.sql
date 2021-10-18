/****** Object:  Procedure [dbo].[CPConnectWithMMF]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
CPConnectWithMMF
	@CarePlanID as bigint,
	@MMFID as bigint
AS
BEGIN
	-- declare working variables
	DECLARE @cpStatus int = 2
	DECLARE @cpActivated bit = 0
	DECLARE @cpProgramType varchar(100) = ''
	DECLARE @cpMVDID varchar(20) = ''
	DECLARE @cpCaseID varchar(100) = ''

	DECLARE @mmfCaseID varchar(100) = ''
	DECLARE @mmfProgramType varchar(max) = ''
	DECLARE @mmfSectionCompleted varchar(max) = '5'
	DECLARE @mmfMVDID varchar(20) = ''
	DECLARE @mmfhistoryID int = 0
		 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF ((@CarePlanID < 1) AND (@MMFID < 1))
	BEGIN
		PRINT 'Care Plan ID OR Member Management Form ID are required'
		RETURN 1
	END

	-- if CarePlanID > 0 then collect proper data from care plan
	IF (@CarePlanID > 0)
	BEGIN
		SELECT @cpMVDID = MVDID, @cpStatus = CarePlanStatus, @cpActivated = Activated, @cpProgramType = CarePlanType, @cpCaseID = CaseID from MainCarePlanMemberIndex where CarePlanID = @CarePlanID
		IF (@cpStatus > 0)
		BEGIN
			PRINT 'Care Plan is closed. No action'
			RETURN 2
		END
		IF (@cpActivated < 1)
		BEGIN
			PRINT 'Care Plan is not Activated. No action'
			RETURN 3
		END
		IF (LEN(RTRIM(@cpCaseID)) > 0)
		BEGIN
			PRINT 'Care Plan is already associated to a Case. No action'
			RETURN 4
		END
	END

	-- if MMFID > 0 then collect proper data from member management form
	IF (@MMFID > 0)
	BEGIN
		SELECT @mmfMVDID = MVDID, @mmfProgramType = CaseProgram, @mmfSectionCompleted = IsNull(SectionCompleted,'0'), @mmfCaseID = CaseID from ABCBS_MemberManagement_Form where ID = @MMFID
		IF (@mmfSectionCompleted > '2')
		BEGIN
			PRINT 'MMF is locked. No action'
			RETURN 5
		END
		IF (LEN(RTRIM(@mmfCaseID)) < 1)
		BEGIN
			PRINT 'MMF is not yet a Case. No action'
			RETURN 6
		END
	END

	-- we believe we got either care plan or MMF or both
	IF (@cpMVDID > '')
	BEGIN
		-- check to see if we already have MMF, otherwise, try to find a form
		IF (len(RTRIM(@mmfMVDID)) < 1)
		BEGIN
			SELECT @MMFID = ID, @mmfMVDID = MVDID, @mmfProgramType = CaseProgram, @mmfSectionCompleted = IsNull(SectionCompleted,'0'), @mmfCaseID = CaseID 
			from ABCBS_MemberManagement_Form 
			where MVDID = @cpMVDID and IsNull(SectionCompleted,'0') < 3 and UPPER(RTRIM(IsNull(CaseProgram,''))) = UPPER(RTRIM(@cpProgramType))
		END
		-- At this point, we should have a form or there is no action
		IF (len(RTRIM(@mmfCaseID)) > 0)
		BEGIN
			UPDATE MainCarePlanMemberIndex set CaseID = @mmfCaseID where CarePlanID = @CarePlanID
			IF (@cpActivated > 0)
			BEGIN
				UPDATE ABCBS_MemberManagement_Form set CarePlanID = @CarePlanID, AuditableCase = 1 where ID = @MMFID
				
				select top 1 @mmfhistoryID = ID from ABCBS_MMFHistory_Form where OriginalFormID = @MMFID order by id desc
				UPDATE ABCBS_MMFHistory_Form set CarePlanID = @CarePlanID, AuditableCase = 1 where ID = @mmfhistoryID
			END
			ELSE
			BEGIN
				UPDATE ABCBS_MemberManagement_Form set CarePlanID = @CarePlanID where ID = @MMFID

				select top 1 @mmfhistoryID = ID from ABCBS_MMFHistory_Form where OriginalFormID = @MMFID order by id desc				
				UPDATE ABCBS_MMFHistory_Form set CarePlanID = @CarePlanID where ID = @mmfhistoryID
			END
		END
	END
	ELSE
	BEGIN
		-- we do not have a care plan, so try to find one based on the information from MMF
		-- we want a CP that is not closed, has been activated and has not been associated to a case and belongs to this member and program type
		SELECT DISTINCT
		@CarePlanID = FIRST_VALUE( CarePlanID ) OVER ( PARTITION BY MVDID ORDER BY CASE WHEN LEN(RTRIM(IsNull(CaseID,''))) < 1 THEN 1 ELSE 2 END ),
		@cpMVDID = FIRST_VALUE( MVDID ) OVER ( PARTITION BY MVDID ORDER BY CASE WHEN LEN(RTRIM(IsNull(CaseID,''))) < 1 THEN 1 ELSE 2 END ),
		@cpStatus = FIRST_VALUE( CarePlanStatus ) OVER ( PARTITION BY MVDID ORDER BY CASE WHEN LEN(RTRIM(IsNull(CaseID,''))) < 1 THEN 1 ELSE 2 END ),
		@cpActivated = FIRST_VALUE( Activated ) OVER ( PARTITION BY MVDID ORDER BY CASE WHEN LEN(RTRIM(IsNull(CaseID,''))) < 1 THEN 1 ELSE 2 END ),
		@cpProgramType = FIRST_VALUE( CarePlanType ) OVER ( PARTITION BY MVDID ORDER BY CASE WHEN LEN(RTRIM(IsNull(CaseID,''))) < 1 THEN 1 ELSE 2 END ),
		@cpCaseID = FIRST_VALUE( CaseID ) OVER ( PARTITION BY MVDID ORDER BY CASE WHEN LEN(RTRIM(IsNull(CaseID,''))) < 1 THEN 1 ELSE 2 END )
		from
		MainCarePlanMemberIndex 
		where
		MVDID = @mmfMVDID
		and CarePlanStatus < 1
		and Activated > 0
		and UPPER(RTRIM(IsNull(CarePlanType,''))) = UPPER(RTRIM(@mmfProgramType));

		IF (LEN(RTRIM(IsNull(@cpMVDID,''))) > 0)
		BEGIN
			UPDATE MainCarePlanMemberIndex set CaseID = @mmfCaseID where CarePlanID = @CarePlanID
			IF (@cpActivated > 0)
			BEGIN
				UPDATE ABCBS_MemberManagement_Form set CarePlanID = @CarePlanID, AuditableCase = 1 where ID = @MMFID
				
				select top 1 @mmfhistoryID = ID from ABCBS_MMFHistory_Form where OriginalFormID = @MMFID order by id desc
				UPDATE ABCBS_MMFHistory_Form set CarePlanID = @CarePlanID, AuditableCase = 1 where ID = @mmfhistoryID
			END
			ELSE
			BEGIN
				UPDATE ABCBS_MemberManagement_Form set CarePlanID = @CarePlanID where ID = @MMFID
				
				select top 1 @mmfhistoryID = ID from ABCBS_MMFHistory_Form where OriginalFormID = @MMFID order by id desc				
				UPDATE ABCBS_MMFHistory_Form set CarePlanID = @CarePlanID where ID = @mmfhistoryID
			END
		END
	END
END