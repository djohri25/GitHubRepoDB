/****** Object:  Procedure [dbo].[Get_ARBCBS_UpdateLangPref]    Committed by VersionSQL https://www.versionsql.com ******/

/*
    [PersonalHarm] [bit] NULL,
	[PermissionToSpeak] [bit] NULL,
	[LangPreference] [bit] NULL,
	[Other1] [bit] NULL,
	[Other1Delete] [bit] NULL,
	[Other2 [bit] NULL,
	[Other2Delete] [bit] NULL,
	[Other3] [bit] NULL,
	[Other3Delete] [bit] NULL,
	[Other4] [bit] NULL,
	[Other4Delete] [bit] NULL,
	[Other5] [bit] NULL,
	[Other5Delete] [bit] NULL,
*/

CREATE PROCEDURE [dbo].[Get_ARBCBS_UpdateLangPref]
	@MVDID varchar(20),
	@CustID int,
	@UserName varchar(20),
	@ProductID int,
	@PrimaryLanguage varchar(max)
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
	[PersonalHarm] [bit] NULL,
	[PHComment] [varchar](max) NULL,
	[PHDate] [datetime] NULL,
	[PermissionToSpeak] [bit] NULL,
	[PermToSpeakComment] [varchar](max) NULL,
	[PermToSpeakDate] [datetime] NULL,
	[LangPreference] [bit] NULL,
	[LangPrefComment] [varchar](max) NULL,
	[LangPrefDate] [datetime] NULL,
	[Other1] [bit] NULL,
	[Other1Comment] [varchar](max) NULL,
	[OtherDate1] [datetime] NULL,
	[Other1Delete] [bit] NULL,
	[Other2] [bit] NULL,
	[Other2Comment] [varchar](max) NULL,
	[OtherDate2] [datetime] NULL,
	[Other2Delete] [bit] NULL,
	[Other3] [bit] NULL,
	[Other3Comment] [varchar](max) NULL,
	[OtherDate3] [datetime] NULL,
	[Other3Delete] [bit] NULL,
	[Other4] [bit] NULL,
	[Other4Comment] [varchar](max) NULL,
	[OtherDate4] [datetime] NULL,
	[Other4Delete] [bit] NULL,
	[Other5] [bit] NULL,
	[Other5Comment] [varchar](max) NULL,
	[OtherDate5] [datetime] NULL,
	[Other5Delete] [bit] NULL,
	[OtherCount] [int] NULL
	)

	INSERT INTO @ARBCBS_MemberAlert
	(      
		[MVDID] ,
		[CustID] ,
		[UserName] ,
		[ProductID],
		[LangPrefComment]
	)
	VALUES
	(
		@MVDID,
		@CustID,
		@UserName,
		@ProductID,
		@PrimaryLanguage
	);

	MERGE dbo.ARBCBS_MemberAlert WITH (HOLDLOCK) AS T
    USING @ARBCBS_MemberAlert AS S
    ON T.MVDID = S.MVDID 
	AND T.CustID = S.CustID 
	AND T.ProductID = S.ProductID 
    WHEN MATCHED 
    THEN 
    UPDATE SET T.LangPreference = 1,
			T.[LangPrefComment] = @PrimaryLanguage, T.LangPrefDate = GetUTCDate()
	WHEN NOT MATCHED THEN INSERT
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
		[OtherCount] 
	)
	VALUES
	(
	  		@MVDID,
			@CustID,
			@UserName,
			@ProductID,
			0,
			NULL,
			NULL,
			0,
			NULL,
			NULL,
			1,
			@PrimaryLanguage,
			GETUTCDATE(),
			0,
			NULL,
			NULL,
			0,
			0,
			NULL,
			NULL,
			0,
			0,
			NULL,
		    NULL,
			0,
			0,
			NULL,
			NULL,
			0,
			0,
			NULL,
			NULL,
			0,
			NULL
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