/****** Object:  Procedure [dbo].[uspMMOLockActiveForms]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[uspMMOLockActiveForms]
AS
/*
Author:			Ed Zanelli
Create date:	2020-12-30
Description:	Lock Monthly Member Overview Form 
Example:		EXEC [dbo].[uspMMOLockActiveForms]

Modified Date			Modified By				Comments
2021-10-04				Sunil Nokku				Add CST offset.	
												Enable entry to Chart History
*/
BEGIN
	DECLARE @v_eom datetime = DATEADD( DAY, 1, EOMONTH( DATEADD( MONTH, -1, getDate() ) ) );

	DECLARE @v_offset int

	SELECT @v_offset = -CAST(SUBSTRING(current_utc_offset,3,1) AS INT) + CASE WHEN is_currently_dst = 1 THEN 0 ELSE -1 END 
	FROM sys.time_zone_info where name = 'Central Standard Time' 

	INSERT INTO
	HPAlertNote
	(
		Note,
		AlertStatusID,
		DateCreated,
		CreatedBy,
		DateModified,
		ModifiedBy,
		MVDID,
		CreatedByType,
		ModifiedByType,
		Active,
		SendToHP,
		SendToPCP,
		SendToNurture,
		SendToNone,
		LinkedFormType,
		LinkedFormID,
		NoteTypeID,
		IsDelete
	)
	SELECT
	'Locked | Monthly Member Overview Saved.' Note,
	0 AlertStatusID,
	getDate() DateCreated,
	'executive1' CreatedBy,
	getDate() DateModified,
	'executive1' ModifiedBy,
	mmo.MVDID,
	'HP' CreatedByType,
	'HP' ModifiedByType,
	1 Active,
	0 SendToHP,
	0 SendToPCP,
	0 SendToNurture,
	0 SendToNone,
	'ABCBS_MonthlyMemberOverview' LinkedFormType,
	mmo.ID LinkedFormID,
	175 NoteTypeID,
	0 IsDelete
	FROM
	ABCBS_MonthlyMemberOverview_Form mmo
	LEFT OUTER JOIN HPAlertNote hpan
	ON hpan.LinkedFormType = 'ABCBS_MonthlyMemberOverview'
	AND hpan.LinkedFormID = mmo.ID
	AND hpan.IsDelete = 0
	WHERE
	DATEADD( hh,@v_offset,mmo.FormDate ) < @v_eom
	AND mmo.IsLocked != 'Yes'
	--AND hpan.ID IS NULL
	ORDER BY
	mmo.ID;

	MERGE INTO
	ABCBS_MonthlyMemberOverview_Form d
	USING
	(
		SELECT
		mmo.ID
		FROM
		ABCBS_MonthlyMemberOverview_Form mmo
/*
		INNER JOIN HPAlertNote hpan
		ON hpan.LinkedFormType = 'ABCBS_MonthlyMemberOverview'
		AND hpan.LinkedFormID = mmo.ID
		AND hpan.IsDelete = 0
*/
		WHERE
		DATEADD( hh,@v_offset,mmo.FormDate ) < @v_eom
		AND mmo.IsLocked != 'Yes'
	) s
	ON
	(
		d.ID = s.ID
	)
	WHEN MATCHED THEN UPDATE SET
	d.IsLocked = 'Yes';

END;