/****** Object:  Procedure [dbo].[Get_MDGroups_by_Customer_With_TinNames]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_MDGroups_by_Customer_With_TinNames] @Cust_ID int
AS
BEGIN
	SET NOCOUNT ON;

CREATE TABLE #tempGroups(id int,GroupName varchar(100), SecondaryName varchar(1000),Active bit)

INSERT INTO #tempGroups
(
    id,
    GroupName,
    SecondaryName,
    Active
)
SELECT distinct ID
      ,GroupName,ISNULL(SecondaryName + ' ' + '(' +GroupName+')',GroupName) AS SecondaryName
      ,Active
FROM MDGroup
WHERE CustID_Import = @Cust_ID --11
	and Active = 1 
	and groupname NOT IN ('dchpbeta1','dchpbeta2','dchpbeta3','XXXXXXXXX') 
ORDER BY id

--INSERT INTO #tempGroups
--(
--    id,
--    GroupName,
--    SecondaryName,
--    Active)
--VALUES
--(
--    0, -- id - int
--    'ALL', -- GroupName - varchar
--    'ALL', -- SecondaryName - varchar
--    1
--)
--SELECT * FROM #tempGroups tg ORDER BY SecondaryName

SELECT * FROM #tempGroups tg ORDER BY SecondaryName

DROP TABLE #tempGroups
END

/*
select * from MDGroup where GroupName = '461450004'
select * from MDGroup where GroupName = '463640887'
*/

--EXEC [Get_MDGroups_by_Customer_With_TinNames] @Cust_ID = 11