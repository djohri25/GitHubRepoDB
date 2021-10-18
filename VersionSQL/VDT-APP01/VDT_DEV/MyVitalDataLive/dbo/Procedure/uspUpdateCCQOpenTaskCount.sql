/****** Object:  Procedure [dbo].[uspUpdateCCQOpenTaskCount]    Committed by VersionSQL https://www.versionsql.com ******/

/*
DROP PROCEDURE
uspUpdateCCQOpenTaskCount;
*/

CREATE PROCEDURE
-- ALTER PROCEDURE
uspUpdateCCQOpenTaskCount
(
	@p_MVDID varchar(20),
	@p_OpenTaskCount int OUTPUT
)
AS
BEGIN
	MERGE INTO
	ComputedCareQueue destination
	USING
	(
		SELECT
		ct.MVDID,
		COUNT( DISTINCT ct.TaskId ) AS OpenTaskCount
		FROM
		(
		  SELECT DISTINCT
		  t.MVDID,
		  tal.TaskId,
		  FIRST_VALUE( tal.StatusId ) OVER ( PARTITION BY t.MVDID, tal.TaskId ORDER BY tal.ID DESC ) StatusId
		  FROM
		  Task t
		  INNER JOIN TaskActivityLog tal
		  ON tal.TaskId = t.id
		  WHERE
		  t.MVDID = @p_MVDID
		) ct
		INNER JOIN Lookup_Generic_Code tt
		ON tt.CodeId = ct.StatusId
		AND tt.Label != 'Completed'
		GROUP BY
		ct.MVDID
		EXCEPT
		SELECT
		ccq.MVDID,
		ccq.OpenTaskCount
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
	destination.OpenTaskCount = source.OpenTaskCount;

	SELECT
	@p_OpenTaskCount = OpenTaskCount
	FROM
	ComputedCareQueue ccq
	WHERE
	MVDID = @p_MVDID;
END;