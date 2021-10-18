/****** Object:  Procedure [dbo].[CheckForActiveMMF]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CheckForActiveMMF] 
	-- Add the parameters for the stored procedure here
	@TempMVDID varchar(20),
	@MainMVDID varchar(20)
AS
BEGIN

	SELECT TOP(1)
		mmf.ID, 'A' as MemberItem, 'Temp' as Name, mmf.MVDID, mmf.FormDate, fm.MemberID, fm.MemberFirstName, fm.MemberLastName, fm.MemberMiddleName
	FROM
		[dbo].[ABCBS_MemberManagement_Form] mmf
		Join [dbo].[finalMember] fm on fm.MVDID = mmf.MVDID
	WHERE
		mmf.MVDID = @TempMVDID AND SectionCompleted < 3 AND (IsLocked IS NULL  OR IsLocked = 'No')
		
	UNION ALL
	
	SELECT TOP(1)
		mmf.ID, 'B' as MemberItem, 'Main' as Name, mmf.MVDID, mmf.FormDate, fm.MemberID, fm.MemberFirstName, fm.MemberLastName, fm.MemberMiddleName
	FROM
		[dbo].[ABCBS_MemberManagement_Form] mmf
		Join [dbo].[finalMember] fm on fm.MVDID = mmf.MVDID
	WHERE
		mmf.MVDID = @MainMVDID AND SectionCompleted < 3 AND (IsLocked IS NULL  OR IsLocked = 'No')
	

END;