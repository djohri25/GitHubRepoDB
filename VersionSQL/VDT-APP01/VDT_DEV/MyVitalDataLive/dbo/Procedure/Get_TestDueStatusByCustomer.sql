/****** Object:  Procedure [dbo].[Get_TestDueStatusByCustomer]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:
-- Create date:
-- Description:
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================

CREATE PROCEDURE [dbo].[Get_TestDueStatusByCustomer]
@CustID varchar(50),
@Username varchar(1000)=null

AS
IF (@CustID = '0' AND @Username IS NOT NULL)
BEGIN
CREATE TABLE #TempNPI(NPI varchar(100))

INSERT INTO #TempNPI
select distinct(d.npi) from dbo.MDUser a
		join Link_MDAccountGroup b on a.ID = b.MDAccountID
		join dbo.MDGroup c on b.MDGroupID = c.ID
		join dbo.Link_MDGroupNPI d on c.ID = d.MDGroupID
		where Username = @Username

SELECT DISTINCT ltds.id,Name 
FROM dbo.LookupTestDueStatus  ltds 
JOIN dbo.Link_TestDueStatus_Customer ltdsc ON ltds.ID = ltdsc.StatusID
WHERE  active = 1 AND ltds.ParentID IS null
AND ltdsc.CustID in (select distinct a.cust_id as cust_id from HPCustomer a
		join dbo.Lookup_DRLink_NPI_to_CustID b on 
		a.cust_id = b.cust_id where b.NPI in (Select NPI from #TempNPI) 
		AND b.Cust_ID != 7
		)
END

ELSE
BEGIN
SELECT DISTINCT ltds.id,Name 
FROM dbo.LookupTestDueStatus  ltds 
JOIN dbo.Link_TestDueStatus_Customer ltdsc ON ltds.ID = ltdsc.StatusID
WHERE ltdsc.CustID = @CustID AND active = 1 AND ltds.ParentID IS null
END


-- exec [dbo].[Get_TestDueStatusByCustomer] '10',null
-- exec [dbo].[Get_TestDueStatusByCustomer] '0','gmarin'