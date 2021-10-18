/****** Object:  Procedure [dbo].[Merge_NurseLicensure]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/17/2019
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Merge_NurseLicensure]
AS
BEGIN

SET NOCOUNT ON;

--If no new data available leave here, don't do anyhting
--Otherwise the NO MATCHED BY SOURCE on the MERGE statement will delete all the data
IF NOT EXISTS( SELECT 1 FROM [dbo].[ABCBS_NurseLicense]  )
RETURN


/****** Script for MERGE NurseLicensure data  ******/
MERGE NurseLicensure AS T
USING [dbo].[ABCBS_NurseLicense] AS S
ON T.UserName = S.NetworkID AND ISNULL(T.State,'') = ISNULL(S.LicenseState,'') AND ISNULL(T.County,'') = ISNULL(S.County,'')
	
--NOT MATCHED: these are the rows from the source table that does not have any matching rows in the target table. In the diagram, they are shown as orange. 
--In this case, you need to add the rows from the source table to the target table. Note that NOT MATCHED is also known as NOT MATCHED BY TARGET.

WHEN NOT MATCHED BY TARGET THEN INSERT ([State],
		[UserName],
		[LicenseType],
		[LicenseStart],
		[LicenseEnd],
		[StateIssued],
		[CompactState],
		[Status],
		[IsActive],
		[County]
	  )
	  VALUES
	  (
	    S.[LicenseState],
		S.[NetworkID],
		S.[License],
		S.[LicenseCredentialDate],
		S.[LicenseExpirationDate],
		S.[StateIssued],
		S.[CompactState],
		'1',
		'1',
		S.[County]
	  )
	  --;

--NO MATCHED BY SOURCE: these are the rows in the target table that does not match any rows in the source table. They are shown as green in the diagram. 
--If you want to synchronize the target table with the data from the source table, then you will need to use this match condition to delete rows from the target table.	
WHEN NOT MATCHED BY SOURCE THEN DELETE;

END