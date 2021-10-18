/****** Object:  Procedure [dbo].[Upd_ActiveMembers]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 8/17/2011
-- Description:	Update Active member flag based on the termination date of their insurance
-- 06/08/2017	Marc De Luca	Changed @recipients
-- =============================================
CREATE PROCEDURE [dbo].[Upd_ActiveMembers]
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @activeDateLimit date, @driscollActiveDateLimit date

	SELECT @activeDateLimit = dateadd(DD,-90, getdate()),
		   @driscollActiveDateLimit = dateadd(DD,-1, getdate())
	
	--Too few active members! Send an error notice.
	IF ((SELECT COUNT(*)
		FROM [dbo].[Link_MemberId_MVD_Ins]
		WHERE active = 1
		AND mvdid IN
		(
			SELECT icenumber
			FROM [dbo].[MainInsurance]
			WHERE terminationDate IS NOT NULL
				AND terminationDate >= CONVERT( DATE ,GETDATE()) 
		)
		AND Cust_ID = 11) < 100000)
	BEGIN
		EXEC msdb.dbo.sp_send_dbmail @profile_name='VD-APP01',
		@recipients='alerts@vitaldatatech.com', 
		@subject='Driscoll Member Counts - ERROR',
		@body='The driscoll member counts are to low, check to see if eligbility has been procesed. Sender: [dbo].[Upd_ActiveMembers]'
	
		SELECT @driscollActiveDateLimit = DATEADD(DD,-15, GETDATE())
	END

	UPDATE [dbo].[Link_MemberId_MVD_Ins]
	SET [Active] = 0
	WHERE mvdid IN
		(
			SELECT icenumber
			FROM [dbo].[MainInsurance]
			WHERE terminationDate IS NOT NULL
				AND terminationDate < @activeDateLimit
		)
		AND Cust_ID <> 11
		AND [Active] = 1
	
	UPDATE [dbo].[Link_MemberId_MVD_Ins]
	SET [Active] = 1
	WHERE mvdid IN
		(
			SELECT icenumber
			FROM [dbo].[MainInsurance]
			WHERE terminationDate IS NOT NULL
				AND terminationDate >= @activeDateLimit
		)
		AND Cust_ID <> 11
		AND [Active] = 0

	-- *** SPECIFIC TO DRISCOLL ***
	UPDATE [dbo].[Link_MemberId_MVD_Ins]
	SET [Active] = 0
	WHERE mvdid IN
		(
			SELECT icenumber
			FROM [dbo].[MainInsurance]
			WHERE terminationDate IS NOT NULL
				AND terminationDate < @driscollActiveDateLimit
		)
		AND Cust_ID = 11
		AND [Active] = 1

	-- Check for Newborn Record created
	UPDATE [dbo].[Link_MemberId_MVD_Ins]
	SET [Active] = 0
	WHERE mvdid IN
		(
			SELECT icenumber
			FROM [dbo].[MainInsurance]
			WHERE terminationDate IS NULL
		)
		AND (insmemberid LIKE '%A' OR insmemberid LIKE '%B' OR insmemberid LIKE '%C'  )
		AND Cust_ID = 11
		AND [Active] = 1

	UPDATE [dbo].[Link_MemberId_MVD_Ins]
	SET [Active] = 1
	WHERE mvdid IN
		(
			SELECT icenumber
			FROM [dbo].[MainInsurance]
			WHERE terminationDate IS NOT NULL
				AND terminationDate >= @driscollActiveDateLimit
		)
		AND Cust_ID = 11
		AND [Active] = 0
	-- *** END DRISCOLL ***
END