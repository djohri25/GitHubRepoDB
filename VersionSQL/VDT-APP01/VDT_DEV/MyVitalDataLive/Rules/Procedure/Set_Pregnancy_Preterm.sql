/****** Object:  Procedure [Rules].[Set_Pregnancy_Preterm]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [Rules].[Set_Pregnancy_Preterm]
(
 @Cust_ID	int

)
AS
BEGIN
SET NOCOUNT ON;
--set @Cust_ID = 11

Declare @MinMonthID	VARCHAR(10), @MaxMonthID	VARCHAR(10),@MDate	Date, @ICENum VARCHAR(30), @MonthID	Varchar(10)
Declare @i int
select @MonthID = MAX(MonthID) from Rules.MainPersonalStats where Cust_ID = @Cust_ID

IF OBJECT_ID ('TempDB.dbo.#Temp_PreMet_Preg_Cond','U') is not null
Drop table #Temp_PreMet_Preg_Cond

Create table #Temp_PreMet_Preg_Cond
(
	Cust_ID			INT,
	ICENUMBER		Varchar(30),
	CodeDesc		VARCHAR(200),
	Code			VARCHAR(20),
	MonthID			VARCHAR(10)
)

IF OBJECT_ID ('TempDB.dbo.#Temp_preg','U') is not null
Drop table #Temp_preg

Create table #Temp_preg
(
	Cust_ID			INT,
	ICENUMBER		VARCHAR(30),
	MinMonthID		VARCHAR(10),
	MaxMonthID		VARCHAR(10)
)


INSERT INTO #Temp_PreMet_Preg_Cond (Cust_ID, ICENUMBER, CodeDesc, Code, MonthID)
 select distinct L.Cust_ID, MC2.ICENUMBER, MC2.OtherName as Second_CodeDesc,MC2.Code as Second_Code ,--, MC2.ReportDate as Second_reportdate
 CAST(DATEPART (Year, MC2.ReportDate) as VARCHAR(4)) + CASE WHEN LEN(DATEPART (Month, MC2.ReportDate)) =1 THEN '0'+CAST(DATEPART (Month, MC2.ReportDate) as VARCHAR(2)) ELSE  CAST(DATEPART (Month, MC2.ReportDate) as VARCHAR(2)) END as MonthID
 FROM MainCondition MC1 JOIN MainCondition MC2 ON MC1.ICENUMBER = MC2.ICENUMBER
 JOIN MainMedication MM on MM.ICENUMBER = MC2.ICENUMBER
 JOIN Link_MemberId_MVD_Ins L ON L.MVDID = MC2.ICENUMBER
 Where L.Cust_ID = @Cust_ID 
 and (MC1.Code like '%644.2%' or MC1.Code like '%O60.1%'or MC1.Code like '%O60.2%' ) and MC1.ReportDate < MC2.ReportDate
 and (MC2.Code like '%Z34.0%' or MC2.code like '%o09.21%' ) and MC2.Code not in (SELECT * FROM dbo.Get_ICDCodesList ('O60')) 
 --and MC2.ICENUMBER in ('LR155721','DM639008')
 ORDER BY  MC2.ICENUMBER

 CREATE NONCLUSTERED INDEX [IX_Temp_PreMet_Preg_Cond] ON #Temp_PreMet_Preg_Cond (Cust_ID ASC, ICENUMBER ASC, MonthID ASC)

INSERT INTO #Temp_preg (Cust_ID, ICENUMBER, MinMonthID,MaxMonthID)
SELECT T.Cust_ID, ICENUMBER, MIN(T.MonthID) as MinMonthID, MAX(T.MONTHID) as MaxMonthID
FROM #Temp_PreMet_Preg_Cond T JOIN Rules.MainPersonalStats P ON T.Cust_ID = P.Cust_ID and T.ICENUMBER = P.MVDID and T.MONTHID = P.MONTHID
Where P.CUst_ID = @Cust_ID
GROUP BY T.Cust_ID, T.ICENUMBER

CREATE NONCLUSTERED INDEX [IX_Temp_preg] ON #Temp_preg (Cust_ID ASC, ICENUMBER ASC, MinMonthID ASC, MaxMonthID ASC)

 While EXISTS (Select 1 from #Temp_preg)
 BEGIN
	 
	 Select top 1 @ICENum = ICENUMBER, @MinMonthID = MinMonthID, @MaxMonthID = MaxMonthID from #Temp_preg 
	 Select @MDate = LEFT(@MinMonthID,4) +'-'+RIGHT(@MinMonthID,2)+'-'+'01'
	 
	 IF EXISTS( SELECT 1 FROM #Temp_preg T LEFT JOIN Rules.MainPersonalStats P ON T.ICENUMBER = P.MVDID 
								where icenumber = @ICENum and P.MonthID = @MinMonthID
				)
		BEGIN
			UPDATE P 
			SET P.Preg_Cond = 1
			--SELECT * 
			FROM #Temp_preg T LEFT JOIN Rules.MainPersonalStats P ON T.ICENUMBER = P.MVDID 
			where icenumber = @ICENum and P.MonthID = @MinMonthID and T.Cust_ID = @Cust_ID
		END
		ELSE
		BEGIN
			
			INSERT INTO Rules.MainPersonalStats (Cust_ID, MVDID, MemberID,MonthID, Preg_Cond)
			SELECT T.Cust_ID as cust_id, T.ICENUMBER, L.InsMemberId, @MinMonthID, 1 as preg_cond
			FROM #Temp_preg T --LEFT JOIN Rules.MainPersonalStats P ON T.ICENUMBER = P.MVDID --and T.MinMonthID = P.MONTHID
			JOIN Link_MemberId_MVD_Ins L ON L.MVDID = T.ICENUMBER and T.Cust_ID = L.Cust_ID
			where L.Cust_ID = @Cust_ID and T.icenumber = @ICENum and @MinMonthID <= @MonthID
		END

	 set @i = 1
	 While (@i <9)
	 BEGIN
		 Select @MDate = DATEADD(Month, 1, @MDate)
		 Select @MinMonthID = CAST(DATEPART (Year, @MDate) as VARCHAR(4)) + CASE WHEN LEN(DATEPART (Month, @MDate)) =1 THEN '0'+CAST(DATEPART (Month, @MDate) as VARCHAR(2)) ELSE  CAST(DATEPART (Month, @MDate) as VARCHAR(2)) END
		 --Print @MDate
		 --print @MinMonthID

		IF EXISTS( SELECT 1 FROM #Temp_preg T LEFT JOIN Rules.MainPersonalStats P ON T.ICENUMBER = P.MVDID 
								where icenumber = @ICENum and P.MonthID = @MinMonthID
				)
		BEGIN
			UPDATE P 
			SET P.Preg_Cond = 1
			--SELECT * 
			FROM #Temp_preg T LEFT JOIN Rules.MainPersonalStats P ON T.ICENUMBER = P.MVDID 
			where icenumber = @ICENum and P.MonthID = @MinMonthID and T.Cust_ID = @Cust_ID
		END
		ELSE
		BEGIN
			
			INSERT INTO Rules.MainPersonalStats (Cust_ID, MVDID, MemberID,MonthID, Preg_Cond)
			SELECT T.Cust_ID as cust_id, T.ICENUMBER, L.InsMemberId, @MinMonthID, 1 as preg_cond
			FROM #Temp_preg T --LEFT JOIN Rules.MainPersonalStats P ON T.ICENUMBER = P.MVDID --and T.MinMonthID = P.MONTHID
			JOIN Link_MemberId_MVD_Ins L ON L.MVDID = T.ICENUMBER and T.Cust_ID = L.Cust_ID
			where L.Cust_ID = @Cust_ID and T.icenumber = @ICENum and @MinMonthID <= @MonthID
		END

		Set @i = @i+1
		--Print @i
		IF (@i = 9 and @MinMonthID < @MaxMonthID)
		BEGIN
			SET @MinMonthID = @MaxMonthID
			Select @MDate = LEFT(@MinMonthID,4) +'-'+RIGHT(@MinMonthID,2)+'-'+'01'
			Select @MDate = DATEADD(Month, -1, @MDate)
			SET @i = 0
			--Print 'I became 9'
			--print @i
			--print @MDate
			--print @MinMonthID
		END
		 
	 END
	
	Delete from #Temp_preg Where ICENUMBER = @ICENum
 END

END