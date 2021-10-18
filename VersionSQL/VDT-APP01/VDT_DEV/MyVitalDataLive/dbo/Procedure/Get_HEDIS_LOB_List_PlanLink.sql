/****** Object:  Procedure [dbo].[Get_HEDIS_LOB_List_PlanLink]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Updates:
--	Date			User		Updates
------------------------------------------------
--	06/23/2016		dpatel		Updated query to accept input @CustID parameter and doesn't return hard-coded value of CustId = 11
-- =============================================
CREATE PROCEDURE [dbo].[Get_HEDIS_LOB_List_PlanLink]
	(@CustID int)
AS
BEGIN

	CREATE TABLE #TempTable(LOB nchar(10))

	INSERT INTO #TempTable (LOB)
	VALUES ('ALL') 

	INSERT INTO #TempTable (LOB) 
	SELECT DISTINCT (LOB) FROM [dbo].[Final_HEDIS_Member_FULL]
	WHERE CustID = @CustID AND
		  LOB IS NOT NULL

	UPDATE #TempTable
	SET LOB = 
        (
            CASE
                WHEN (LOB = 'M') THEN 'STAR'
                WHEN (LOB = 'C') THEN 'CHIP'
				ELSE LOB
            END
        )

	SELECT * FROM #TempTable
END