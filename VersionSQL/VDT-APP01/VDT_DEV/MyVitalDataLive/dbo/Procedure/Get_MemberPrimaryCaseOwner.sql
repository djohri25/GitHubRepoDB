/****** Object:  Procedure [dbo].[Get_MemberPrimaryCaseOwner]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
Get_MemberPrimaryCaseOwner
(
	@p_MVDID nvarchar(30),
	@p_FormID bigint = NULL OUTPUT,
	@p_CaseProgram nvarchar(max) = NULL OUTPUT,
	@p_CaseID nvarchar(100) = NULL OUTPUT,
	@p_AssignedUser nvarchar(max) = NULL OUTPUT
)
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DROP TABLE IF EXISTS
	#ProgramPriority;

	CREATE TABLE
	#ProgramPriority
	(
		Type nvarchar(255),
		Priority int
	);
	INSERT INTO #ProgramPriority( Type, Priority ) VALUES ( 'Case Management', 1 );
	INSERT INTO #ProgramPriority( Type, Priority ) VALUES ( 'Maternity', 2 );
	INSERT INTO #ProgramPriority( Type, Priority ) VALUES ( 'Chronic Condition Management', 3 );
	INSERT INTO #ProgramPriority( Type, Priority ) VALUES ( 'Clinical Support', 4 );
	INSERT INTO #ProgramPriority( Type, Priority ) VALUES ( 'Social Work', 5 );

	SELECT DISTINCT
	@p_FormID = FIRST_VALUE( mmf.ID ) OVER ( PARTITION BY mmf.MVDID ORDER BY pp.Priority, mmf.FormDate ),
	@p_CaseProgram = FIRST_VALUE( mmf.CaseProgram ) OVER ( PARTITION BY mmf.MVDID ORDER BY pp.Priority, mmf.FormDate ),
	@p_CaseID = FIRST_VALUE( mmf.CaseID ) OVER ( PARTITION BY mmf.MVDID ORDER BY pp.Priority, mmf.FormDate ),
	@p_AssignedUser = FIRST_VALUE( mmf.q1CaseOwner ) OVER ( PARTITION BY mmf.MVDID ORDER BY pp.Priority, mmf.FormDate )
	FROM
	ABCBS_MMFHistory_Form mmf
	INNER JOIN HPAlertNote hpan
	ON hpan.LinkedFormType = 'ABCBS_MMFHistory'
	AND hpan.LinkedFormID = mmf.ID
	AND ISNULL( hpan.IsDelete, 0 ) = 0
	INNER JOIN #ProgramPriority pp
	ON pp.Type = mmf.CaseProgram
	WHERE
	mmf.MVDID = @p_MVDID
	AND ISNULL( mmf.CaseID, '' ) != ''
	AND ISNULL( mmf.qCloseCase, 'No' ) = 'No'
	AND ISNULL( mmf.q1CaseCloseDate, '1900-01-01' ) = '1900-01-01';
END;