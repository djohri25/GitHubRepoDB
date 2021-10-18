/****** Object:  Procedure [dbo].[Get_MDGroups_by_Customer_With_TinNames_Test]    Committed by VersionSQL https://www.versionsql.com ******/

-- exec [Get_MDGroups_by_Customer_With_TinNames_Test] 10

CREATE PROCEDURE [dbo].[Get_MDGroups_by_Customer_With_TinNames_Test] @Cust_ID int
AS
BEGIN
	SET NOCOUNT ON;

CREATE TABLE #tempGroups(id int, GroupName varchar(100), SecondaryName varchar(1000),Active bit)

INSERT INTO #tempGroups
(
    id,
    GroupName,
    SecondaryName,
    Active
)
SELECT MAX(ID) AS ID
      ,ltrim(rtrim(GroupName))
	  ,ltrim(rtrim(ISNULL(SecondaryName + ' ' + '(' +GroupName+')',GroupName))) AS SecondaryName
      ,Active
FROM  MDGroup_Test
WHERE CustID_Import = @Cust_ID and Active = 1 
GROUP BY 
	   GroupName
	  ,ISNULL(SecondaryName + ' ' + '(' +GroupName+')',GroupName) 
	  ,Active
ORDER BY id

SELECT * FROM #tempGroups tg ORDER BY SecondaryName

DROP TABLE #tempGroups
END

--60448	 204985401     	 A THERAPY CONNECTION                                                                                ( 204985401     )	1
--59898	204985401      	A THERAPY CONNECTION                                                                                 (204985401      )	1