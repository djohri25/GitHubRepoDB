/****** Object:  Procedure [dbo].[uspUpdateCCQOpenCaseCount]    Committed by VersionSQL https://www.versionsql.com ******/

/*
DROP PROCEDURE
uspUpdateCCQOpenCaseCount;
*/

CREATE PROCEDURE
-- ALTER PROCEDURE
uspUpdateCCQOpenCaseCount
(
	@p_MVDID varchar(20),
	@p_OpenCaseCount int OUTPUT
)
AS
BEGIN
	MERGE INTO
	ComputedCareQueue destination
	USING
	(
		SELECT
		mmf.MVDID,
		COUNT(1) OpenCaseCount
		FROM
		ABCBS_MemberManagement_Form mmf
		WHERE
		mmf.MVDID = @p_MVDID
		GROUP BY
		mmf.MVDID
		EXCEPT
		SELECT
		ccq.MVDID,
		ccq.OpenCaseCount
		FROM
		ComputedCareQueue ccq
		WHERE
		ccq.MVDID = @p_MVDID
	) source
	ON
	(
		source.MVDID = destination.MVDID
	)
	WHEN MATCHED THEN
	UPDATE SET
	destination.OpenCaseCount = source.OpenCaseCount;

	SELECT
	@p_OpenCaseCount = OpenCaseCount
	FROM
	ComputedCareQueue ccq
	WHERE
	MVDID = @p_MVDID;
END;