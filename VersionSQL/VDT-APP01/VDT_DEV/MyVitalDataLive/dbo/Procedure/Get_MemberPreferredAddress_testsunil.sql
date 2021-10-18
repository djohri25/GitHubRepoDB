/****** Object:  Procedure [dbo].[Get_MemberPreferredAddress_testsunil]    Committed by VersionSQL https://www.versionsql.com ******/

/*
11/1/2021		SunilNokku		Readuncommitted on MMF
*/

CREATE PROCEDURE
[dbo].[Get_MemberPreferredAddress_testsunil]
(
	@p_MVDID varchar(255),
	@p_Address1 nvarchar(255) OUTPUT,
	@p_Address2 nvarchar(255) OUTPUT,
	@p_City nvarchar(255) OUTPUT,
	@p_State nvarchar(2) OUTPUT,
	@p_PostalCode nvarchar(50) OUTPUT,
	@p_HomePhone nvarchar(50) OUTPUT,
	@p_CellPhone nvarchar(50) OUTPUT,
	@p_WorkPhone nvarchar(50) OUTPUT,
	@p_FAX nvarchar(50) OUTPUT,
	@p_Email nvarchar(50) OUTPUT,
	@p_Language nvarchar(50) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	--DECLARE @v_MVDID nvarchar(255) 
	--SET @v_MVDID = @p_MVDID

	CREATE TABLE #TempAddress (
	p_Address1 nvarchar(255) ,
	p_Address2 nvarchar(255) ,
	p_City nvarchar(255) ,
	p_State nvarchar(2) ,
	p_PostalCode nvarchar(50) ,
	p_HomePhone nvarchar(50) ,
	p_CellPhone nvarchar(50) ,
	p_WorkPhone nvarchar(50) ,
	p_FAX nvarchar(50) ,
	p_Email nvarchar(50) ,
	p_Language nvarchar(50) )

	INSERT INTO #TempAddress

	SELECT
	ISNULL( csme.Address1, fm.Address1 ),
	ISNULL( csme.Address2, fm.Address2 ),
	ISNULL( csme.City, fm.City ),
	ISNULL( csme.State, fm.State ),
	ISNULL( csme.PostalCode, fm.Zipcode ),
	ISNULL( csme.HomePhone, fm.HomePhone ),
	csme.CellPhone,
	ISNULL( csme.WorkPhone, fm.WorkPhone ),
	ISNULL( csme.FAXPhone, fm.FAX ),
	ISNULL( csme.Email, ISNULL( mef.Email, ISNULL( mmf.email, fm.Email ) ) ),
	ISNULL( csme.Language, ISNULL( fm.WrittenLanguage, fm.Language ) )
	FROM
	FinalMember fm
	LEFT OUTER JOIN
	(
		SELECT DISTINCT
		IceNumber,
		Address1,
		Address2,
		City,
		State,
		PostalCode,
		HomePhone,
		CellPhone,
		WorkPhone,
		FAXPhone,
		Email,
		Language,
		RANK() OVER ( PARTITION BY IceNumber ORDER BY RecordNumber DESC ) record_rank
		FROM
		CareSpaceMemberEdit
		WHERE
		IceNumber = @p_MVDID
		AND IsPrimary = 1
	) csme
	ON csme.IceNumber = fm.MVDID
	AND csme.record_rank = 1
	LEFT OUTER JOIN
	(
		SELECT DISTINCT
		MVDID,
		FIRST_VALUE( q15Email ) OVER ( PARTITION BY MVDID ORDER BY CASE WHEN q15Email IS NOT NULL THEN 1 ELSE 0 END, FormDate DESC ) Email
		FROM
		ABCBS_MaternityEnrollment_Form
		WHERE
		--dbo.MVDIsNull( q15Email ) = 0
		CASE WHEN q15Email IS NULL THEN 1
			WHEN q15Email = '' THEN 1
			WHEN q15Email = 'NULL' THEN 1
			ELSE 0
			END = 0
	) mef
	ON mef.MVDID = fm.MVDID
	LEFT OUTER JOIN
	(
		SELECT DISTINCT
		MVDID,
		FIRST_VALUE( qEmail ) OVER ( PARTITION BY MVDID ORDER BY CASE WHEN qEmail IS NOT NULL THEN 1 ELSE 0 END, FormDate DESC ) Email
		FROM
		ABCBS_MemberManagement_Form mmf1 (READUNCOMMITTED)
		WHERE
		--dbo.MVDIsNull( qEmail ) = 0
		CASE WHEN qEmail IS NULL THEN 1
			WHEN qEmail = '' THEN 1
			WHEN qEmail = 'NULL' THEN 1
			ELSE 0
			END = 0
	) mmf
	ON mmf.MVDID = fm.MVDID
	WHERE
	fm.MVDID = @p_MVDID;

	SELECT * FROM #TempAddress

END;