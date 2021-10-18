/****** Object:  Procedure [dbo].[uspGetMobileMessageRecipients]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
[dbo].[uspGetMobileMessageRecipients]
(
	@p_MVDID nvarchar(30)
)
AS
BEGIN
	DROP TABLE IF EXISTS
	#UserType;
	CREATE TABLE
	#UserType
	(
		Name nvarchar(255)
	);

	INSERT INTO #UserType( Name ) VALUES ( 'VDT_Assign_UserType_CaseMgmt' );
	INSERT INTO #UserType( Name ) VALUES ( 'VDT_Assign_UserType_CaseMgmt_WQI' );
	INSERT INTO #UserType( Name ) VALUES ( 'VDT_Assign_UserType_CaseMgmt_Specialty_Cancer' );
	INSERT INTO #UserType( Name ) VALUES ( 'VDT_Assign_UserType_CaseMgmt_Specialty_Diabetes' );
	INSERT INTO #UserType( Name ) VALUES ( 'VDT_Assign_UserType_CaseMgmt_Specialty_Ortho' );
	INSERT INTO #UserType( Name ) VALUES ( 'VDT_Assign_UserType_CaseMgmt_Specialty_Renal' );
	INSERT INTO #UserType( Name ) VALUES ( 'VDT_Assign_UserType_CaseMgmt_Specialty_Transplant' );
	INSERT INTO #UserType( Name ) VALUES ( 'VDT_Assign_UserType_ChronicConditionMgmt' );
	INSERT INTO #UserType( Name ) VALUES ( 'VDT_Assign_UserType_Maternity' );
	INSERT INTO #UserType( Name ) VALUES ( 'VDT_Assign_UserType_SocialWork' );

	SELECT
	u.*
	FROM
	Final_MemberOwner fmo
	CROSS APPLY
	(
		SELECT DISTINCT
		anu.ID,
		anu.Username,
		anu.FirstName,
		anu.LastName
		FROM
		AspNetUsers anu
		INNER JOIN AspNetUserInfo anui
		ON anui.UserID = anu.ID
		INNER JOIN #UserType ut
		ON anui.Groups LIKE CONCAT( '%', ut.Name, '%' )
		WHERE
		anu.ID = fmo.UserID
	) u
	WHERE
	fmo.MVDID = @p_MVDID
	AND IsDeactivated = 0;
END;