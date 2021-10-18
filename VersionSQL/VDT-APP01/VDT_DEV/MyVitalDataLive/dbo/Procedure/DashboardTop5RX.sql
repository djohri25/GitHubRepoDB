/****** Object:  Procedure [dbo].[DashboardTop5RX]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[DashboardTop5RX]
(
	@Cust_ID		INT,
	@StartDate	Datetime = NULL,
	@EndDate	Datetime = NULL
)
AS 
BEGIN
--Declare @StartDate	Datetime, @EndDate	Datetime, @Cust_ID	INT
--set @Cust_ID = 10
--set @StartDate = NULL
--set @EndDate = NULL

SET NOCOUNT ON;

IF @StartDate is null
BEGIN
	Select @StartDate = DATEADD(Month, DATEDIFF(MONTH, 0, GETDATE())-11, 0)
END

IF @EndDate is null
BEGIN
select @EndDate = DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE()), -1) 
END

--select @StartDate, @EndDate

IF OBJECT_ID('tempDB.dbo.#Temp_Meds','U') is not null
Drop table #Temp_Meds
CREATE TABLE #Temp_Meds
(
	Cust_ID		INT, 
	StartDate		Datetime, 
	NDC_NUM		VARCHAR(60), 
	RxDrug		VARCHAR(100),
	RecordNumber		INT
)

INSERT INTO #Temp_Meds
SELECT Cust_ID, StartDate, M.Code as NDC_NUM, RxDrug, M.RecordNumber as  RecordNumber
	FROM MainMedication M JOIN Link_MemberID_MVD_Ins L on L.MVDID = M.ICENUMBER 
	Where Cust_ID = @Cust_ID and StartDate between @StartDate and @EndDate



DECLARE @RXPres Table 
(
	Cust_ID		INT, MonthID	VARCHAR(6), NDC_NUM		VARCHAR(60), RxDrug		VARCHAR(100), [#NoDrugPrescribed]	INT 
)

INSERT INTO @RXPres
SELECT Cust_ID, CAST(Year(StartDate) as VARCHAR(4))+''+ CASE WHEN LEN(DATEPART (Month, StartDate)) =1 THEN '0'+CAST(DATEPART (Month, StartDate) as VARCHAR(2)) ELSE  CAST(DATEPART (Month, StartDate) as VARCHAR(2)) END as MONTHID, NDC_NUM, RxDrug, COUNT(RecordNumber) as  [#NoDrugPrescribed]  
	FROM #Temp_Meds 
	GROUP BY Cust_ID, CAST(Year(StartDate) as VARCHAR(4))+''+CASE WHEN LEN(DATEPART (Month, StartDate)) =1 THEN '0'+CAST(DATEPART (Month, StartDate) as VARCHAR(2)) ELSE  CAST(DATEPART (Month, StartDate) as VARCHAR(2)) END, NDC_NUM, RxDrug

Select A.Cust_ID, A.MONTHID, A.NDC_NUM, A.RxDrug, A.#NoDrugPrescribed, ROW_NUMBER() OVER(Partition BY A.MonthID ORDER BY A.#NoDrugPrescribed Desc) as RowRank 
INTO #Temp_RXPres
FROM @RXPres A

---- Monthly
select R.Cust_ID, R.MONTHID, R.NDC_NUM, R.[#NoDrugPrescribed], R.RxDrug, R.RowRank from #Temp_RXPres R
Where R.RowRank <=5
ORDER BY R.Cust_ID, R.MONTHID,  R.#NoDrugPrescribed desc

drop table #Temp_RXPres

END