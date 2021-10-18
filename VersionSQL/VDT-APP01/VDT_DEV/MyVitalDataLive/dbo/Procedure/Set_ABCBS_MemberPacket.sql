/****** Object:  Procedure [dbo].[Set_ABCBS_MemberPacket]    Committed by VersionSQL https://www.versionsql.com ******/

/*
DROP PROCEDURE
Set_ABCBS_MemberPacket;
*/

CREATE PROCEDURE
[dbo].[Set_ABCBS_MemberPacket]
(
	@p_ID bigint = NULL OUTPUT,
	@p_MVDID nvarchar(255),
	@p_ProcedureName nvarchar(255),
	@p_FormID nvarchar(100) = NULL
)
AS
BEGIN
	INSERT INTO
	ABCBS_MemberPacket
	(
		MVDID,
		ProcedureName,
		FormID,
		CreatedDatetime
	)
	VALUES
	(
		@p_MVDID,
		@p_ProcedureName,
		@p_FormID,
		getDate()
	);

	SET @p_ID = SCOPE_IDENTITY();
END;