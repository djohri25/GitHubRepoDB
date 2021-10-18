/****** Object:  Procedure [dbo].[GetInvalidAddressLettersReport]    Committed by VersionSQL https://www.versionsql.com ******/

/*CREATEd by : Sunil Nokku
Date: 08/17/2020
This SP generates a report of Letter Members with Invalid Address, runs daily after LetterBatch.
--Date			Modified by				Modification
--20201103		Sunil Nokku				Send Distinct Members on Report, TFS 3856
*/

CREATE PROCEDURE [dbo].[GetInvalidAddressLettersReport]
AS
BEGIN

SET NOCOUNT ON;

	DROP TABLE IF EXISTS #InvalidAddressReport

	CREATE TABLE #InvalidAddressReport
	(	[MemberID] [varchar](15) NULL,
		[MemberFirstName] [varchar](50) NULL,
		[MemberLastName] [varchar](50) NULL,
		[SubscriberID] [varchar](10) NULL,
		[Suffix] [varchar](15) NULL,
		[DateOfBirth] [date] NULL
	)

	INSERT INTO #InvalidAddressReport
	SELECT DISTINCT MemberID,
		MemberFirstName,
		MemberLastName,
		SubscriberID,
		Suffix,
		DateOfBirth
	FROM LetterMembersInvalidAddress
	WHERE ISNULL(ProcessedDate,'')=''

	UPDATE LetterMembersInvalidAddress
	SET ProcessedDate = GETDATE()
	WHERE ISNULL(ProcessedDate,'')='' 

	SELECT DISTINCT MemberID,
		MemberFirstName,
		MemberLastName,
		SubscriberID,
		Suffix,
		DateOfBirth,*
	FROM #InvalidAddressReport			--TFS 3856
		
END