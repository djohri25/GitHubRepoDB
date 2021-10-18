/****** Object:  Procedure [dbo].[Get_ARBCBS_MemberAlert]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_ARBCBS_MemberAlert] 
@MVDID varchar(20),
@ProductID int,
@CustID int,
@UserName varchar(20)
AS
/*
Unknown			Unknown			Created
2021-05-19		Ed Zanelli		Changed source of GrpInitvCd from FinalEligibility to FinalMember
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @isPersonalYes bit;
	DECLARE @personalHarmComment nvarchar(255) = 'Member has Personal Harm alert; refer to CSW';

	SELECT TOP 1
	@isPersonalYes = PersonalHarm
	FROM
	ComputedMemberAlert (readuncommitted)
	WHERE
	MVDID = @MVDID; 
	
	IF
	EXISTS
	(
		SELECT
		*
		FROM
		ARBCBS_MemberAlert MA (readuncommitted)
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
			PersonalHarm = 'Y',
			PHComment = @personalHarmComment,
			PHDate = getDate()
			WHERE
			MVDID = @MVDID;
		END;

		SELECT
		ma.ID,
		ma.MVDID,
		ma.CustID,
		ma.UserName,
		ma.ProductID,
		ma.PersonalHarm,
		ma.PHComment,
		ma.PHDate,
		ma.PermissionToSpeak,
		ma.PermToSpeakComment,
		ma.PermToSpeakDate,
		ma.LangPreference,
		ma.LangPrefComment,
		ma.LangPrefDate,
		ma.Other1,
		ma.Other1Comment,
		ma.OtherDate1,
		ma.Other1Delete,
		ma.Other2,
		ma.Other2Comment,
		ma.OtherDate2,
		ma.Other2Delete,
		ma.Other3,
		ma.Other3Comment,
		ma.OtherDate3,
		ma.Other3Delete,
		ma.Other4,
		ma.Other4Comment,
		ma.OtherDate4,
		ma.Other4Delete,
		ma.Other5,
		ma.Other5Comment,
		ma.OtherDate5,
		ma.Other5Delete,
		ma.OtherCount,
		CASE
		WHEN fm.GrpInitvCD = 'EMB' THEN CAST( 1 AS bit )
		ELSE CAST( 0 AS bit )
		END GrpInitiativeWQI,
		CASE
		WHEN fm.GrpInitvCD = 'EMB' THEN getDate()
		ELSE NULL
		END GrpInitiativeWQIDate,
		CASE
		WHEN fm.GrpInitvCD = 'EMB' THEN 'Group Initiative: WQI'
		ELSE NULL
		END GrpInitiativeWQIComment,
		CASE
		WHEN fm.GrpInitvCD = 'GRD' THEN CAST( 1 AS bit )
		ELSE CAST( 0 AS bit )
		END GrpInitiativeGR,
		CASE
		WHEN fm.GrpInitvCD = 'GRD' THEN getDate()
		ELSE NULL
		END GrpInitiativeGRDate,
		CASE
		WHEN fm.GrpInitvCD = 'GRD' THEN 'Group Initiative: Grand Rounds'
		ELSE NULL
		END GrpInitiativeGRComment
		FROM
		ARBCBS_MemberAlert ma (readuncommitted)
		JOIN FinalMember fm (readuncommitted)
		ON fm.MVDID = ma.MVDID
/*
		CROSS APPLY
	   	(
 			SELECT
    		*
    		FROM
    		(
   				SELECT
   				*,
   				ROW_NUMBER() OVER ( PARTITION BY MVDID ORDER BY MemberTerminationDate DESC, RecordID DESC ) row_number
   				FROM
   				FinalEligibility e
				WHERE
   				e.MVDID = ma.MVDID
   			) fe
   			WHERE fe.row_number = 1
    	) fe
*/
		WHERE
		ma.MVDID = @MVDID
		AND ma.ProductID = @ProductID
		AND ma.CustID = @CustID;
	END	
	ELSE	  
	BEGIN
		SELECT 
		NULL AS ID,
		MA.MVDID,
		NULL AS CustID,
		NULL AS UserName,
		NULL AS ProductID,
		MA.PersonalHarm,
		CASE WHEN MA.PersonalHarm = 1 THEN @personalHarmComment ELSE NULL END AS PHComment,
		CASE WHEN MA.PersonalHarm = 1 THEN getDate() ELSE NULL END AS PHDate,
		0 AS PermissionToSpeak,
		NULL AS PermToSpeakComment,
		NULL AS PermToSpeakDate,
		0 AS LangPreference,
		NULL AS LangPrefComment,
		NULL AS LangPrefDate,
		NULL AS Other1,
		NULL AS Other1Comment,
		NULL AS OtherDate1,
		NULL AS Other1Delete,
		0 AS Other2,
		NULL AS Other2Comment,
		NULL AS OtherDate2,
		0 AS Other2Delete,
		0 AS Other3,
		NULL AS Other3Comment,
		NULL AS OtherDate3,
		0 AS Other3Delete,
		0 AS Other4,
		NULL AS Other4Comment,
		NULL AS OtherDate4,
		0 AS Other4Delete,
		0 AS Other5,
		NULL AS Other5Comment,
		NULL AS OtherDate5,
		0 AS Other5Delete,
		NULL AS OtherCount,
		CASE
		WHEN fm.GrpInitvCD = 'EMB' THEN CAST( 1 AS bit )
		ELSE CAST( 0 AS bit )
		END GrpInitiativeWQI,
		CASE
		WHEN fm.GrpInitvCD = 'EMB' THEN getDate()
		ELSE NULL
		END GrpInitiativeWQIDate,
		CASE
		WHEN fm.GrpInitvCD = 'EMB' THEN 'Group Initiative: WQI'
		ELSE NULL
		END GrpInitiativeWQIComment,
		CASE
		WHEN fm.GrpInitvCD = 'GRD' THEN CAST( 1 AS bit )
		ELSE CAST( 0 AS bit )
		END GrpInitiativeGR,
		CASE
		WHEN fm.GrpInitvCD = 'GRD' THEN getDate()
		ELSE NULL
		END GrpInitiativeGRDate,
		CASE
		WHEN fm.GrpInitvCD = 'GRD' THEN 'Group Initiative: Grand Rounds'
		ELSE NULL
		END GrpInitiativeGRComment
		FROM
		dbo.ComputedMemberAlert ma (readuncommitted)
		JOIN FinalMember fm (readuncommitted)
		ON fm.MVDID = ma.MVDID
/*
		CROSS APPLY
	   	(
 			SELECT
    		*
    		FROM
    		(
   				SELECT
   				*,
   				ROW_NUMBER() OVER ( PARTITION BY MVDID ORDER BY MemberTerminationDate DESC, RecordID DESC ) row_number
   				FROM
   				FinalEligibility e
				WHERE
   				e.MVDID = ma.MVDID
   			) fe
   			WHERE fe.row_number = 1
    	) fe
*/
		WHERE
		MA.MVDID = @MVDID;		
	END;
END;