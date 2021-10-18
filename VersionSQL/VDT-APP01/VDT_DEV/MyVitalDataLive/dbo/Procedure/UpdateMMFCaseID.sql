/****** Object:  Procedure [dbo].[UpdateMMFCaseID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE  [dbo].[UpdateMMFCaseID] (	@MMFFormID bigint, 
									@HistoryFormID bigint, 
									@CaseID varchar(100),
									@ReferralOwner varchar(100) = NULL, 
									@CaseOwner varchar(100) =NULL, 
									@CaseCreateDate Datetime, 
									@User varchar(100) =NULL, 
									@Flag int 
								  )
AS
/*

note:	Update existing MMF and MMFHistory records.  
		@Flag passes parameters 1, 2 or 3 to control write type.
		procedure returns 1 for success and -1 for failure.

Modifications:	WHO		WHEN		WHAT
				Scott	2020-06-22	Created (Database/#3155)

EXEC  UpdateMMFCaseID	@MMFFormID = 1400,
						@HistoryFormID = 14000, 
						@CaseID = 14000, 
						@ReferralOwner = 'NDRICKMAN2', 
						@CaseOwner = 'NDRICKMAN2',
						@CaseCreateDate='2019-10-18', 
						@User = 'executive1',				
						@Flag = 2

SELECT * FROM ABCBS_MemberManagement_Form WHERE ID = 14000
SELECT * FROM ABCBS_MMMFHistory_Form WHERE ID = 14000

*/
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	Declare @MVDID varchar(100);
	 
	 SET @MMFFormID= @CaseID;				    
	
	IF @Flag = 1 
		BEGIN
			BEGIN TRANSACTION;
				UPDATE	ABCBS_MemberManagement_Form 
				SET		CaseID =@CaseID ,
						ReferralOwner=@User, 
						q1CaseOwner= @CaseOwner, 
						q1CaseCreateDate=@CaseCreateDate 
				WHERE	ID = @MMFFormID;

				UPDATE	ABCBS_MMFHistory_Form 
				SET		CaseID = @CaseID,
						ReferralOwner=@User,
						q1CaseOwner= @CaseOwner,
						q1CaseCreateDate=@CaseCreateDate 
				WHERE	ID = @HistoryFormID;
			COMMIT TRANSACTION;
		END

	ELSE IF @Flag = 2
		BEGIN
			BEGIN TRANSACTION;
				UPDATE	ABCBS_MemberManagement_Form 
				SET		CaseID = @CaseID,
						ReferralOwner=@ReferralOwner,
						q1CaseOwner= @CaseOwner,
						q15AssignTo='User',
						q16CareQ=NULL,
						q18User=@CaseOwner,
						q19AssignedUser=@CaseOwner,
						q1CaseCreateDate=@CaseCreateDate 
				WHERE	ID = @MMFFormID;

				UPDATE ABCBS_MMFHistory_Form 
				SET		CaseID = @CaseID,
						ReferralOwner=@ReferralOwner,
						q1CaseOwner= @CaseOwner,
						q15AssignTo='User',
						q16CareQ=NULL,
						q18User=@CaseOwner,
						q19AssignedUser=@CaseOwner,
						q1CaseCreateDate=@CaseCreateDate 
				WHERE	ID = @HistoryFormID;
			COMMIT TRANSACTION;
		END

	ELSE IF @Flag=3
		BEGIN
			BEGIN TRANSACTION;
				UPDATE	ABCBS_MemberManagement_Form 
				SET		CaseID = @CaseID,
						q1CaseCreateDate=@CaseCreateDate 
				WHERE	ID = @MMFFormID;

				UPDATE ABCBS_MMFHistory_Form 
				SET		CaseID = @CaseID, 
						q1CaseCreateDate=@CaseCreateDate 
				WHERE	ID = @HistoryFormID;
			COMMIT TRANSACTION;
		END

	RETURN 1	--return 1 for a successful write

END TRY
BEGIN CATCH
	
	PRINT ERROR_MESSAGE()
	RETURN -1			--return -1 to caller in event of error

END CATCH
	
END