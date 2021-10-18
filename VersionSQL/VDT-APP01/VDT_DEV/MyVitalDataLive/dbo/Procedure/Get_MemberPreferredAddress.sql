/****** Object:  Procedure [dbo].[Get_MemberPreferredAddress]    Committed by VersionSQL https://www.versionsql.com ******/

/*
1/11/2021		Sunil Nokku		Readuncommitted on MMF
1/13/2021		Sunil Nokku		Remove MVDIsNull Function
*/

CREATE PROCEDURE
[dbo].[Get_MemberPreferredAddress]
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

	SELECT
	@p_Address1 = ISNULL( csme.Address1, fm.Address1 ),
	@p_Address2 = ISNULL( csme.Address2, fm.Address2 ),
	@p_City = ISNULL( csme.City, fm.City ),
	@p_State = ISNULL( csme.State, fm.State ),
	@p_PostalCode = ISNULL( csme.PostalCode, fm.Zipcode ),
	@p_HomePhone = ISNULL( csme.HomePhone, fm.HomePhone ),
	@p_CellPhone = csme.CellPhone,
	@p_WorkPhone = ISNULL( csme.WorkPhone, fm.WorkPhone ),
	@p_FAX = ISNULL( csme.FAXPhone, fm.FAX ),
	@p_Email = ISNULL( csme.Email, ISNULL( mef.Email, ISNULL( mmf.email, fm.Email ) ) ),
	@p_Language = ISNULL( csme.Language, ISNULL( fm.WrittenLanguage, fm.Language ) )
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
		CASE
		WHEN q15Email IS NULL THEN 1
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
		ABCBS_MemberManagement_Form (READUNCOMMITTED)
		WHERE
		--dbo.MVDIsNull( qEmail ) = 0
		CASE
		WHEN qEmail IS NULL THEN 1
		WHEN qEmail = '' THEN 1
		WHEN qEmail = 'NULL' THEN 1
		ELSE 0
		END = 0
	) mmf
	ON mmf.MVDID = fm.MVDID
	WHERE
	fm.MVDID = @p_MVDID;

END;