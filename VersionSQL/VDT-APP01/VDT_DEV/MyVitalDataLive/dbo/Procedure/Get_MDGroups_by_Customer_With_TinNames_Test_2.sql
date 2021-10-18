/****** Object:  Procedure [dbo].[Get_MDGroups_by_Customer_With_TinNames_Test_2]    Committed by VersionSQL https://www.versionsql.com ******/

-- exec [Get_MDGroups_by_Customer_With_TinNames_Test] 10

CREATE PROCEDURE [dbo].[Get_MDGroups_by_Customer_With_TinNames_Test_2] @Cust_ID int
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
SELECT DISTINCT ID
      ,GroupName,ISNULL(SecondaryName + ' ' + '(' +GroupName+')',GroupName) AS SecondaryName
      ,Active
FROM MDGroup_Test
WHERE CustID_Import = @Cust_ID --10
	and Active = 1 
	and groupname NOT IN ('dchpbeta1','dchpbeta2','dchpbeta3','XXXXXXXXX') 
ORDER BY id

SELECT * FROM 
(
SELECT DISTINCT ID
      ,GroupName
	  ,ISNULL(SecondaryName + ' ' + '(' +GroupName+')',GroupName) AS SecondaryName
      ,Active
	, ROW_NUMBER () OVER (PARTITION BY GroupName ORDER BY ID) rn
FROM MDGroup_Test
WHERE CustID_Import = @Cust_ID and Active = 1 
) AS Der 
WHERE rn=1

SELECT * FROM #tempGroups tg ORDER BY SecondaryName

DROP TABLE #tempGroups
END

/*
select * from MDGroup where GroupName = '461450004'
select * from MDGroup where GroupName = '463640887'
*/

--EXEC [Get_MDGroups_by_Customer_With_TinNames] @Cust_ID = 11