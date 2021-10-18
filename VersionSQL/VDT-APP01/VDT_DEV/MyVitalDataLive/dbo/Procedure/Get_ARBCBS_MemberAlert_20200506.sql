/****** Object:  Procedure [dbo].[Get_ARBCBS_MemberAlert_20200506]    Committed by VersionSQL https://www.versionsql.com ******/

create PROCEDURE [dbo].[Get_ARBCBS_MemberAlert_20200506] 
	@MVDID varchar(20),
	@ProductID int,
	@CustID int,
	@UserName varchar(20)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @isPersonalYes bit;
	DECLARE @personalHarmComment nvarchar(255) = 'Member has Personal Harm alert; refer to CSW';

	SELECT TOP 1
	@isPersonalYes = PersonalHarm
	FROM
	ComputedMemberAlert
	WHERE
	MVDID = @MVDID; 
	
	IF
	EXISTS
	(
		SELECT
		*
		FROM
		ARBCBS_MemberAlert MA
		WHERE
		MA.MVDID = @MVDID
--		AND UserName = @UserName
	)
	BEGIN
		IF ( @isPersonalYes = 1 )
		BEGIN
			UPDATE
			ARBCBS_MemberAlert
			SET
			PersonalHarm = 1,
			PHComment = @personalHarmComment,
			PHDate = getDate()
			WHERE
			MVDID = @MVDID;
		END;

		SELECT 
		[ID],
		[MVDID],
		[CustID],
		[UserName],
		[ProductID],
		[PersonalHarm],
		[PHComment],
		[PHDate],
		[PermissionToSpeak],
		[PermToSpeakComment],
		[PermToSpeakDate],
		[LangPreference],
		[LangPrefComment],
		[LangPrefDate],
		[Other1],
		[Other1Comment],
		[OtherDate1],
		[Other1Delete],
		[Other2],
		[Other2Comment],
		[OtherDate2],
		[Other2Delete],
		[Other3],
		[Other3Comment],
		[OtherDate3],
		[Other3Delete],
		[Other4],
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
		FROM
		ARBCBS_MemberAlert MA
		WHERE
		MA.MVDID = @MVDID
		AND MA.ProductID = @ProductID
		AND MA.CustID = @CustID;
--		AND MA.UserName = @UserName
	END	
	ELSE	  
	BEGIN
		SELECT 
		NULL AS [ID],
		CMA.[MVDID],
		NULL AS [CustID],
		NULL AS [UserName],
		NULL AS [ProductID],
		CMA.[PersonalHarm],
		CASE WHEN CMA.[PersonalHarm] = 1 THEN @personalHarmComment ELSE NULL END AS [PHComment],
		CASE WHEN CMA.[PersonalHarm] = 1 THEN getDate() ELSE NULL END AS [PHDate],
		0 AS [PermissionToSpeak],
		NULL AS [PermToSpeakComment],
		NULL AS [PermToSpeakDate],
		0 AS [LangPreference],
		NULL AS [LangPrefComment],
		NULL AS [LangPrefDate],
		NULL AS [Other1],
		NULL AS [Other1Comment],
		NULL AS [OtherDate1],
		NULL AS [Other1Delete],
		0 AS [Other2],
		NULL AS [Other2Comment],
		NULL AS [OtherDate2],
		0 AS [Other2Delete],
		0 AS [Other3],
		NULL AS [Other3Comment],
		NULL AS [OtherDate3],
		0 AS [Other3Delete],
		0 AS [Other4],
		NULL AS [Other4Comment],
		NULL AS [OtherDate4],
		0 AS [Other4Delete],
		0 AS [Other5],
		NULL AS [Other5Comment],
		NULL AS [OtherDate5],
		0 AS [Other5Delete],
		NULL AS [OtherCount],
		case when fe.GrpInitvcd = 'EMB' then CAST(1 as bit) else NULL end AS [GrpInitiativeWQI],
		case when fe.GrpInitvcd = 'EMB' then fe.ClientLoadDT else NULL end AS [GrpInitiativeWQIDate],
		NULL AS [GrpInitiativeWQIComment],
		case when fe.GrpInitvcd = 'GRD' then CAST(1 as bit) else NULL end AS [GrpInitiativeGR],
		case when fe.GrpInitvcd = 'GRD' then fe.ClientLoadDT else NULL end AS [GrpInitiativeGRDate],
		NULL AS [GrpInitiativeGRComment]
		FROM
		[dbo].[ComputedMemberAlert] CMA
		left join FinalMemberETL fe on fe.MVDID = CMA.MVDID
		WHERE
		CMA.MVDID = @MVDID;		
	END;
END;