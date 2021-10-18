/****** Object:  Procedure [dbo].[Get_CustomerType_ByTIN]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_CustomerType_ByTIN]
	@PCP_TIN varchar(20)=null
AS
BEGIN
------------------------------------------------------------------------------------------------------------------------------------------
-- Date			Name			Comments
-- 04/21/17		PPetluri		Since MDUser_Member table is old and not sure if we can use this or not, so get the equivalent code to get same output.
------------------------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;

 ------Commented out since this table is very old 
--SELECT TOP 1
--	CASE WHEN HPName='Driscoll' THEN 'Driscoll Health Plan.'
--	ELSE NULL 
--	END AS HPName, CustID
--FROM MDUser_Member WHERE PCP_TIN = LTRIM(RTRIM(@PCP_TIN))
Create table #Temp
(
	HPName		varchar(100),
	CustID		INT
)

INSERT INTO #Temp (HPName, CustID)
SELECT distinct
	CASE WHEN C.Name='Driscoll' THEN 'Driscoll Health Plan.'
		 --WHEN C.Name='Parkland' THEN 'Parkland Health Plan.'
	ELSE NULL 
	END AS HPName, Cust_ID as CustID
FROM MDUser U INNER JOIN [dbo].[Link_MDAccountGroup] L ON L.MDAccountID = U.ID
INNER JOIN MDGroup M ON M.ID = L.MDGroupID 
INNER JOIN HPCustomer C ON C.CUst_ID = M.CustID_Import
 WHERE M.GroupName = LTRIM(RTRIM(@PCP_TIN))
 
IF (select COUNT(*) from #Temp) >1
BEGIN
	SELECT * FROM #Temp where CustID = 11
END
ELSE 
BEGIN
	SELECT * FROM #Temp
END

END