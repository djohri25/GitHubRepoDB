/****** Object:  Procedure [dbo].[Set_ARBCBS_MemberAlert]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Set_ARBCBS_MemberAlert]
	@MVDID varchar(20),
	@CustID int ,
	@UserName varchar(20),
	@ProductID int,
	@PersonalHarm bit = NULL,
	@PHComment varchar(max) = NULL,
	@PHDate datetime = NULL,
	@PermissionToSpeak bit = NULL,
	@PermToSpeakComment varchar(max) = NULL,
	@PermToSpeakDate datetime = NULL,
	@LangPreference bit = NULL,
	@LangPrefComment varchar(max) = NULL,
	@LangPrefDate datetime = NULL,
	@Other1 bit = NULL,
	@Other1Comment varchar(max) = NULL,
	@OtherDate1 datetime = NULL,
	@Other1Delete bit = NULL,
	@Other2 bit = NULL,
	@Other2Comment varchar(max) = NULL,
	@OtherDate2 datetime = NULL,
	@Other2Delete bit = NULL,
	@Other3 bit = NULL,
	@Other3Comment varchar(max) = NULL,
	@OtherDate3 datetime = NULL,
	@Other3Delete bit = NULL,
	@Other4 bit = NULL,
	@Other4Comment varchar(max) = NULL,
	@OtherDate4 datetime = NULL,
	@Other4Delete bit = NULL,
	@Other5 bit = NULL,
	@Other5Comment varchar(max) = NULL,
	@OtherDate5 datetime = NULL,
	@Other5Delete bit = NULL,
	@OtherCount int = NULL,
	@GrpInitiativeWQI varchar(30) = NULL,
	@GrpInitiativeWQIDate datetime = NULL,
	@GrpInitiativeWQIComment varchar(max) = NULL,
	@GrpInitiativeGR varchar(30) = NULL,
	@GrpInitiativeGRDate datetime = NULL,
	@GrpInitiativeGRComment varchar(max) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY  
	DECLARE @ARBCBS_MemberAlert TABLE
	(
	[MVDID] [varchar](20) NOT NULL,
	[CustID] [int] NOT NULL,
	[UserName] [varchar](20) NOT NULL,
	[ProductID] [int] NOT NULL,
	[PersonalHarm] bit NULL,
	[PHComment] [varchar](max) NULL,
	[PHDate] [datetime] NULL,
	[PermissionToSpeak] bit NULL,
	[PermToSpeakComment] [varchar](max) NULL,
	[PermToSpeakDate] [datetime] NULL,
	[LangPreference] bit NULL,
	[LangPrefComment] [varchar](max) NULL,
	[LangPrefDate] [datetime] NULL,
	[Other1] bit NULL,
	[Other1Comment] [varchar](max) NULL,
	[OtherDate1] [datetime] NULL,
	[Other1Delete] [bit] NULL,
	[Other2] bit NULL,
	[Other2Comment] [varchar](max) NULL,
	[OtherDate2] [datetime] NULL,
	[Other2Delete] [bit] NULL,
	[Other3] bit NULL,
	[Other3Comment] [varchar](max) NULL,
	[OtherDate3] [datetime] NULL,
	[Other3Delete] [bit] NULL,
	[Other4] bit NULL,
	[Other4Comment] [varchar](max) NULL,
	[OtherDate4] [datetime] NULL,
	[Other4Delete] [bit] NULL,
	[Other5] bit NULL,
	[Other5Comment] [varchar](max) NULL,
	[OtherDate5] [datetime] NULL,
	[Other5Delete] [bit] NULL,
	[OtherCount] [int] NULL,
	[GrpInitiativeWQI] varchar(30) NULL,
	[GrpInitiativeWQIDate] datetime NULL,
	[GrpInitiativeWQIComment] varchar(max) NULL,
	[GrpInitiativeGR] varchar(30) NULL,
	[GrpInitiativeGRDate] datetime NULL,
	[GrpInitiativeGRComment] varchar(max) NULL
	)
	
	INSERT INTO @ARBCBS_MemberAlert
	(      
		[MVDID] ,
		[CustID] ,
		[UserName] ,
		[ProductID],
		[PersonalHarm] ,
		[PHComment],
		[PHDate],
		[PermissionToSpeak],
		[PermToSpeakComment] ,
		[PermToSpeakDate],
		[LangPreference],
		[LangPrefComment],
		[LangPrefDate] ,
		[Other1] ,
		[Other1Comment] ,
		[OtherDate1],
		[Other1Delete],
		[Other2],
		[Other2Comment],
		[OtherDate2],
		[Other2Delete],
		[Other3],
		[Other3Comment] ,
		[OtherDate3] ,
		[Other3Delete],
		[Other4] ,
		[Other4Comment],
		[OtherDate4],
		[Other4Delete],
		[Other5],
		[Other5Comment],
		[OtherDate5],
		[Other5Delete],
		[OtherCount],
		[GrpInitiativeWQI],
		[GrpInitiativeWQIDate],
		[GrpInitiativeWQIComment],
		[GrpInitiativeGR],
		[GrpInitiativeGRDate],
		[GrpInitiativeGRComment]
	)

		VALUES
		(
		@MVDID,
		@CustID,
		@UserName,
		@ProductID,
		@PersonalHarm,
		@PHComment,
		@PHDate,
		@PermissionToSpeak,
		@PermToSpeakComment,
		@PermToSpeakDate,
		@LangPreference,
		@LangPrefComment,
		@LangPrefDate,
		@Other1,
		@Other1Comment,
		@OtherDate1,
		@Other1Delete,
		@Other2,
		@Other2Comment,
		@OtherDate2,
		@Other2Delete,
		@Other3,
		@Other3Comment,
		@OtherDate3,
		@Other3Delete,
		@Other4,
		@Other4Comment,
		@OtherDate4,
		@Other4Delete,
		@Other5,
		@Other5Comment,
		@OtherDate5,
		@Other5Delete,
		@OtherCount,
		@GrpInitiativeWQI,
		@GrpInitiativeWQIDate,
		@GrpInitiativeWQIComment,
		@GrpInitiativeGR,
		@GrpInitiativeGRDate,
		@GrpInitiativeGRComment
	)
	
	MERGE dbo.ARBCBS_MemberAlert WITH (HOLDLOCK) AS T
    USING
    (
    	SELECT
		ma.[MVDID] ,
		ma.[CustID] ,
		ma.[UserName] ,
		ma.[ProductID],
		CASE
		WHEN cma.PersonalHarm = 1 THEN 1
		ELSE NULL
		END [PersonalHarm],
		CASE
		WHEN cma.PersonalHarm = 1 THEN 'Member has Personal Harm alert; refer to CSW'
		ELSE NULL
		END PHComment,
		CASE
		WHEN cma.PersonalHarm = 1 THEN getDate()
		ELSE NULL
		END [PHDate],
		ma.[PermissionToSpeak],
		ma.[PermToSpeakComment] ,
		ma.[PermToSpeakDate],
		ma.[LangPreference],
		ma.[LangPrefComment],
		ma.[LangPrefDate] ,
		ma.[Other1] ,
		ma.[Other1Comment] ,
		ma.[OtherDate1],
		ma.[Other1Delete],
		ma.[Other2],
		ma.[Other2Comment],
		ma.[OtherDate2],
		ma.[Other2Delete],
		ma.[Other3],
		ma.[Other3Comment] ,
		ma.[OtherDate3] ,
		ma.[Other3Delete],
		ma.[Other4] ,
		ma.[Other4Comment],
		ma.[OtherDate4],
		ma.[Other4Delete],
		ma.[Other5],
		ma.[Other5Comment],
		ma.[OtherDate5],
		ma.[Other5Delete],
		ma.[OtherCount],
		CASE
		WHEN fe.GrpInitvCD = 'EMB' THEN fe.GrpInitvCD
		ELSE NULL
		END GrpInitiativeWQI,
		CASE
		WHEN fe.GrpInitvCD = 'EMB' THEN getDate()
		ELSE NULL
		END GrpInitiativeWQIDate,
		CASE
		WHEN fe.GrpInitvCD = 'EMB' THEN 'Group Initiative: WQI'
		ELSE NULL
		END GrpInitiativeWQIComment,
		CASE
		WHEN fe.GrpInitvCD = 'GRD' THEN fe.GrpInitvCD
		ELSE NULL
		END GrpInitiativeGR,
		CASE
		WHEN fe.GrpInitvCD = 'GRD' THEN getDate()
		ELSE NULL
		END GrpInitiativeGRDate,
		CASE
		WHEN fe.GrpInitvCD = 'GRD' THEN 'Group Initiative: Grand Rounds'
		ELSE NULL
		END GrpInitiativeGRComment
		FROM
    	@ARBCBS_MemberAlert ma
    	LEFT OUTER JOIN ComputedMemberAlert cma
    	ON cma.MVDID = ma.MVDID
    	LEFT OUTER JOIN
    	(
    		SELECT
    		*
    		FROM
    		(
    			SELECT
    			*,
    			ROW_NUMBER() OVER ( PARTITION BY MVDID ORDER BY MemberTerminationDate DESC, RecordID DESC ) row_number
    			FROM
    			FinalEligibility where MVDID = @MVDID
    		) fe
    		WHERE fe.row_number = 1
    	) fe
    	ON fe.MVDID = cma.MVDID
    ) S
    ON T.MVDID = S.MVDID 
	AND T.CustID = S.CustID 
	--AND T.UserName =  S.UserName
	AND T.ProductID = S.ProductID 
    WHEN MATCHED 
    THEN 
    UPDATE SET 
			T.[MVDID] = S.[MVDID],
			T.[CustID] = S.[CustID],
			T.[UserName] = S.[UserName],
			T.[ProductID] = S.[ProductID],
			T.[PersonalHarm] = S.[PersonalHarm],
			T.[PHComment] = S.[PHComment],
			T.[PHDate] = S.[PHDate],
			T.[PermissionToSpeak] = S.[PermissionToSpeak],
			T.[PermToSpeakComment] = S.[PermToSpeakComment],
			T.[PermToSpeakDate] = S.[PermToSpeakDate],
			T.[LangPreference] = S.[LangPreference],
			T.[LangPrefComment] = S.[LangPrefComment],
			T.[LangPrefDate] = S.[LangPrefDate],
			T.[Other1] = S.[Other1],
			T.[Other1Comment] = S.[Other1Comment],
			T.[OtherDate1] = S.[OtherDate1],
			T.[Other1Delete] = S.[Other1Delete],
			T.[Other2] = S.[Other2],
			T.[Other2Comment] = S.[Other2Comment],
			T.[OtherDate2] = S.[OtherDate2],
			T.[Other2Delete] = S.[Other2Delete],
			T.[Other3] = S.[Other3],
			T.[Other3Comment] = S.[Other3Comment],
			T.[OtherDate3] = S.[OtherDate3],
			T.[Other3Delete] = S.[Other3Delete],
			T.[Other4] = S.[Other4],
			T.[Other4Comment] = S.[Other4Comment],
			T.[OtherDate4] = S.[OtherDate4],
			T.[Other4Delete] = S.[Other4Delete],
			T.[Other5] = S.[Other5],
			T.[Other5Comment] = S.[Other5Comment],
			T.[OtherDate5] = S.[OtherDate5],
			T.[Other5Delete] = S.[Other5Delete],
			T.[OtherCount] = S.[OtherCount]
    WHEN NOT MATCHED THEN
    INSERT (
	    [MVDID] ,
		[CustID] ,
		[UserName] ,
		[ProductID],
		[PersonalHarm] ,
		[PHComment],
		[PHDate],
		[PermissionToSpeak],
		[PermToSpeakComment] ,
		[PermToSpeakDate],
		[LangPreference],
		[LangPrefComment],
		[LangPrefDate] ,
		[Other1] ,
		[Other1Comment] ,
		[OtherDate1],
		[Other1Delete],
		[Other2],
		[Other2Comment],
		[OtherDate2],
		[Other2Delete],
		[Other3],
		[Other3Comment] ,
		[OtherDate3] ,
		[Other3Delete],
		[Other4] ,
		[Other4Comment],
		[OtherDate4],
		[Other4Delete],
		[Other5],
		[Other5Comment],
		[OtherDate5],
		[Other5Delete],
		[OtherCount] 
	)
	VALUES
	(
	        S.[MVDID],
			S.[CustID],
			S.[UserName],
			S.[ProductID],
			S.[PersonalHarm],
			S.[PHComment],
			S.[PHDate],
			S.[PermissionToSpeak],
			S.[PermToSpeakComment],
			S.[PermToSpeakDate],
			S.[LangPreference],
			S.[LangPrefComment],
			S.[LangPrefDate],
			S.[Other1],
			S.[Other1Comment],
			S.[OtherDate1],
			S.[Other1Delete],
			S.[Other2],
			S.[Other2Comment],
			S.[OtherDate2],
			S.[Other2Delete],
			S.[Other3],
			S.[Other3Comment],
		    S.[OtherDate3],
			S.[Other3Delete],
			S.[Other4],
			S.[Other4Comment],
			S.[OtherDate4],
			S.[Other4Delete],
			S.[Other5],
			S.[Other5Comment],
			S.[OtherDate5],
			S.[Other5Delete],
			S.[OtherCount]
	);
	 
	END TRY  
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(max);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
        @ErrorMessage = ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(),  
        @ErrorState = ERROR_STATE();  
    
		RAISERROR (@ErrorMessage,
		           @ErrorSeverity,
		           @ErrorState
		           );  
	END CATCH

 
END