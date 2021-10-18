/****** Object:  Procedure [dbo].[ProcessToDoHEDISRaw]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Tim Thein
-- Create date: 03/23/2010
-- Description:	Used in SSIS Package named HEDIS Import to process raw data imported into MainToDoHEDISRaw
-- =============================================
CREATE PROCEDURE [dbo].[ProcessToDoHEDISRaw] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @start datetime
	SET @start = getdate()

	TRUNCATE TABLE MainToDoHEDISStaging

	UPDATE	MainToDoHEDISRaw
	SET		Start = 1, Length = LEN(Measures)
	WHERE	Start IS NULL

	WHILE @@ROWCOUNT > 0
	BEGIN
		INSERT	MainToDoHEDISStaging

		select memberid, major,minor
		from 
		(
			SELECT	MemberID, 
					SUBSTRING(Measures, Start, i - Start) Major, 
					SUBSTRING(Measures, i + 1, CHARINDEX('|', measures, Start) - i - 1) Minor
			FROM
			(
					SELECT	MemberID, Measures, Start, CHARINDEX(';', Measures, Start) i FROM MainToDoHEDISRaw
					WHERE	Start < Length
			) t
		) t2
		where t2.Major not like '%access %'		

		UPDATE	MainToDoHEDISRaw
		SET		Start = CHARINDEX('|', Measures, Start) + 1
		WHERE	Start < Length
	END

	DECLARE @date smalldatetime
	SET @date = GETUTCDATE()

	DELETE	MainToDoHEDIS
	OUTPUT	deleted.MemberID, deleted.Major, deleted.Minor, 'D', @date INTO MainToDoHEDISHistory (MemberID, Major, Minor, Action, Date)
	FROM	MainToDoHEDISStaging a RIGHT JOIN MainToDoHEDIS b ON a.MemberID = b.MemberID AND a.Major = b.Major AND a.Minor = b.Minor
	WHERE	a.MemberID IS NULL AND b.Source is NULL

	INSERT	MainToDoHEDIS (MemberID,Major,Minor)
	OUTPUT	inserted.MemberID, inserted.Major, inserted.Minor, 'I', @date INTO MainToDoHEDISHistory (MemberID, Major, Minor, Action, Date)
	SELECT	a.MemberID, a.Major, a.Minor
	FROM	MainToDoHEDISStaging a LEFT JOIN MainToDoHEDIS b ON a.MemberID = b.MemberID AND a.Major = b.Major AND a.Minor = b.Minor
	WHERE	b.MemberID IS NULL AND b.Source is NULL
		

	SELECT datediff(ms, @start, getdate())
END