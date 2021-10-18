/****** Object:  Function [dbo].[fnABCBSUserMemberCheck]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION
[dbo].[fnABCBSUserMemberCheck]
(
	@UserName nvarchar(256)
)
RETURNS bit
AS
BEGIN

	DECLARE @v_security_abcbs_yn bit = 0;
	DECLARE @v_abcbs_security_group nvarchar(255) = '%VDT_SECURITY_ABCBS%';

	SELECT TOP 1
		@v_security_abcbs_yn = security_abcbs_yn
	FROM
	(
-- Returns one record at most; 1 if the user has ABCBS security access; or, 0 if not
		SELECT
			MAX( 1 ) security_abcbs_yn
		FROM AspNetIdentity.dbo.AspNetUsers anu (readuncommitted)
		INNER JOIN AspNetIdentity.dbo.AspNetUserInfo anui (readuncommitted)
			ON anui.UserId = anu.id AND anui.Groups LIKE @v_abcbs_security_group
		WHERE
			CASE
			WHEN anu.UserName = @UserName THEN 1
			WHEN anu.Id = @UserName THEN 1
			ELSE 0
			END = 1
		UNION
-- Returns 0 (the default)
-- This record will be ignored if the user does not have ABCBS security access
		SELECT
			0 security_abcbs_yn
		EXCEPT
-- Excludes all records from first SELECT if the user has another record without ABCBS security access
		SELECT
			1 security_abcbs_yn
		FROM
			AspNetIdentity.dbo.AspNetUsers anu  (readuncommitted)
			INNER JOIN AspNetIdentity.dbo.AspNetUserInfo anui (readuncommitted)
			ON anui.UserId = anu.id AND anui.Groups NOT LIKE @v_abcbs_security_group
		WHERE
			CASE
			WHEN anu.UserName = @UserName THEN 1
			WHEN anu.Id = @UserName THEN 1
			ELSE 0
			END = 1
	) u
	ORDER BY
		security_abcbs_yn DESC;

	RETURN @v_security_abcbs_yn;
END;