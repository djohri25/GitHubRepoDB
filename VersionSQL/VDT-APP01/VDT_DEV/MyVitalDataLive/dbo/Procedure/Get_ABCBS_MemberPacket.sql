/****** Object:  Procedure [dbo].[Get_ABCBS_MemberPacket]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
Get_ABCBS_MemberPacket
(
	@p_MVDID nvarchar(255),
	@p_ProcedureName nvarchar(255),
	@p_ID bigint = NULL OUTPUT,
	@p_FormID nvarchar(100) = NULL OUTPUT
)
AS
BEGIN

	SELECT
	@p_ID = mp.ID,
	@p_FormID = mp.FormID
	FROM
	ABCBS_MemberPacket mp
	WHERE
	mp.MVDID = @p_MVDID
	AND mp.ProcedureName = @p_ProcedureName
	AND
	CASE
-- Use Contact Form ID if specified
	WHEN @p_FormID IS NULL THEN 1
	WHEN mp.FormID = @p_FormID THEN 1
	ELSE 0
	END = 1
	AND
	CASE
-- Most likely the ID is unknown, but use it if specified
	WHEN @p_ID IS NULL THEN 1
	WHEN mp.ID = @p_ID THEN 1
	ELSE 0
	END = 1;

END;