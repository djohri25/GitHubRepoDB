/****** Object:  Procedure [dbo].[Get_HEDIS_Summary_New]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_HEDIS_Summary_New] (  @TIN varchar(50), @CustID int, @NPI varchar(50) )
AS
SET  @TIN  ='741662481' 
SET @CustID  = 11
SET  @NPI  =''

--DROP TABLE #TEMP_RESULTS

Create Table #TEMP_RESULTS
(testID INT, testAbbr VARCHAR(5), testName VARCHAR(50), FullTestName VARCHAR(50), testType VARCHAR(50), PrevYearPerc DECIMAL(8,2), CurYearToDatePerc DECIMAL(8,2), CurYearOverall DECIMAL(8,2), GoalPerc DECIMAL(8,2), AvgMonthlyDifference  DECIMAL(8,2) ,
QualifyingMemCount INT, CompletedMemCount INT, YearToDateGoalStatus INT, CurYearOverallGoalStatus INT ,PCP_NPI VARCHAR(50),	PCP_GroupID	 VARCHAR(50), CustID INT,duration VARCHAR(50) )

declare @AWC_Total int, @AWC_Complete int, @W34_Total int, @W34_Complete int, @W15_Total int, @W15_Complete int,
		@AMR_Total int,@AMR_Complete int,
     	@AWC_MonthID int, @W34_MonthID int, @W15_MonthID int, @AMR_MonthID int

declare @AWC_PrevYearPerc DECIMAL(8,2), @W15_PrevYearPerc DECIMAL(8,2), @W34_PrevYearPerc DECIMAL(8,2),@AMR_PrevYearPerc DECIMAL(8,2)
declare @AWC_PrevYear_Total DECIMAL(8,2), @AWC_PrevYear_Complete DECIMAL(8,2), @W34_PrevYear_Total DECIMAL(8,2), @W34_PrevYear_Complete DECIMAL(8,2),
	    @W15_PrevYear_Total DECIMAL(8,2), @W15_PrevYear_Complete DECIMAL(8,2),@AMR_PrevYear_Total DECIMAL(8,2), @AMR_PrevYear_Complete DECIMAL(8,2)

declare @Last_AWC_Total int, @Last_AWC_Complete int, @Last_W34_Total int, @Last_W34_Complete int, @Last_W15_Total int, @Last_W15_Complete int, 
        @Last_AMR_Total int, @Last_AMR_Complete int,
        @AWC_Last_MonthID int, @W34_Last_MonthID int, @W15_Last_MonthID int,@AMR_Last_MonthID int

declare @Previous_AWC_Total int, @Previous_AWC_Complete int, @Previous_W34_Total int, @Previous_W34_Complete int, @Previous_W15_Total int, @Previous_W15_Complete int, 
        @Previous_AMR_Total int, @Previous_AMR_Complete int,
        @Previous_MonthID int

Select @AWC_MonthID = Max(MonthID) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AWCMember] where Custid = @CustID
Select @W34_MonthID = Max(MonthID) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W34Member] where Custid = @CustID
Select @W15_MonthID = Max(MonthID) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W15Member] where Custid = @CustID
SELECT @AMR_MonthID = Max(MonthID) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AMRMember] where Custid = @CustID


Select @AWC_Last_MonthID = @AWC_MonthID -1
Select @W34_Last_MonthID = @W34_MonthID -1
Select @W15_Last_MonthID = @W15_MonthID -1
SELECT @AMR_Last_MonthID = @AMR_MonthID -1

If ( @NPI = 'All' or @NPI is null or @NPI = '' )
BEGIN

		select @AWC_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AWCMember]
		where CustID = @CustID and TIN = @TIN and MonthID = @AWC_MonthID

		select @AWC_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AWCMember]
		where CustID = @CustID and TIN = @TIN and IsComplete = 1 and MonthID = @AWC_MonthID

		select @W34_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W34Member]
		where CustID = @CustID and TIN = @TIN and MonthID = @W34_MonthID

		select @W34_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W34Member]
		where CustID = @CustID and TIN = @TIN and IsComplete = 1 and MonthID = @W34_MonthID

	    select @W15_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W15Member]
		where CustID = @CustID and TIN = @TIN and MonthID = @W15_MonthID

		select @W15_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W15Member]
		where CustID = @CustID and TIN = @TIN and IsComplete = 1 and MonthID = @W15_MonthID

		SELECT @AMR_Total =Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AMRMember]
		where CustID = @CustID and TIN = @TIN and MonthID = @AMR_MonthID

		select @AMR_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AMRMember]
		where CustID = @CustID and TIN = @TIN and IsComplete = 1 and MonthID = @AMR_MonthID


		

		select @AWC_PrevYear_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AWCMember]
		where CustID = @CustID and TIN = @TIN 
		AND LEFT(MonthID,4) = '2014'

		select @AWC_PrevYear_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AWCMember]
		where CustID = @CustID and TIN = @TIN and IsComplete = 1 
		AND LEFT(MonthID,4) = '2014'

		select @W34_PrevYear_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W34Member]
		where CustID = @CustID and TIN = @TIN 
		AND LEFT(MonthID,4) = '2014'

		select @W34_PrevYear_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W34Member]
		where CustID = @CustID and TIN = @TIN and IsComplete = 1 
		AND LEFT(MonthID,4) = '2014'

	    select @W15_PrevYear_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W15Member]
		where CustID = @CustID and TIN = @TIN 
		AND LEFT(MonthID,4) = '2014'

		select @W15_PrevYear_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W15Member]
		where CustID = @CustID and TIN = @TIN and IsComplete = 1 
		AND LEFT(MonthID,4) = '2014'
		--select @AMR_PrevYear_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AMRMember]
		--where CustID = @CustID and TIN = @TIN 
		--AND LEFT(MonthID,4) = '2014'

--select @AMR_PrevYear_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AMRMember]
--where CustID = @CustID and TIN = @TIN and IsComplete = 1 
--AND LEFT(MonthID,4) = '2014'


END
Else
BEGIN

		select @AWC_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AWCMember]
		where CustID = @CustID and TIN = @TIN and NPI = @NPI and MonthID = @AWC_MonthID

		select @AWC_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AWCMember]
		where CustID = @CustID and TIN = @TIN and IsComplete = 1 and NPI = @NPI and MonthID = @AWC_MonthID
				
		select @W34_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W34Member]
		where CustID = @CustID and TIN = @TIN and NPI = @NPI and MonthID = @W34_MonthID

		select @W34_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W34Member]
		where CustID = @CustID and TIN = @TIN and IsComplete = 1  and NPI = @NPI and MonthID = @W34_MonthID

	    select @W15_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W15Member]
		where CustID = @CustID and TIN = @TIN  and NPI = @NPI and MonthID = @W15_MonthID

		select @W15_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W15Member]
		where CustID = @CustID and TIN = @TIN and IsComplete = 1  and NPI = @NPI and MonthID = @W15_MonthID

		select @AMR_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AMRMember]
		where CustID = @CustID and TIN = @TIN  and NPI = @NPI and MonthID = @AMR_MonthID

		select @AMR_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AMRMember]
		where CustID = @CustID and TIN = @TIN and IsComplete = 1  and NPI = @NPI and MonthID = @AMR_MonthID



		select @AWC_PrevYear_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AWCMember]
		where CustID = @CustID and TIN = @TIN and NPI = @NPI 
		AND LEFT(MonthID,4) = '2014'

		select @AWC_PrevYear_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AWCMember]
		where CustID = @CustID and TIN = @TIN and IsComplete = 1 and NPI = @NPI 
		AND LEFT(MonthID,4) = '2014'
				
		select @W34_PrevYear_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W34Member]
		where CustID = @CustID and TIN = @TIN and NPI = @NPI 
		AND LEFT(MonthID,4) = '2014'

		select @W34_PrevYear_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W34Member]
		where CustID = @CustID and TIN = @TIN and IsComplete = 1  and NPI = @NPI 
		AND LEFT(MonthID,4) = '2014'

	    select @W15_PrevYear_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W15Member]
		where CustID = @CustID and TIN = @TIN  and NPI = @NPI 
		AND LEFT(MonthID,4) = '2014'

		select @W15_PrevYear_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W15Member]
		where CustID = @CustID and TIN = @TIN and IsComplete = 1  and NPI = @NPI 
		AND LEFT(MonthID,4) = '2014'

		--select @AMR_PrevYear_Total= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AMRMember]
		--where CustID = @CustID and TIN = @TIN  and NPI = @NPI 
		--AND LEFT(MonthID,4) = '2014'

		--select @AMR_PrevYear_Complete= Count(*) from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_AMRMember]
		--where CustID = @CustID and TIN = @TIN and IsComplete = 1  and NPI = @NPI AND LEFT(MonthID,4) = '2014'

END

--testID	testAbbr	testName	FullTestName	testType	                              PrevYearPerc	CurYearToDatePerc	CurYearOverall	GoalPerc	AvgMonthlyDifference	QualifyingMemCount	CompletedMemCount	YearToDateGoalStatus	CurYearOverallGoalStatus	PCP_NPI	PCP_Group

--ID	CustID	duration
--1	W15	Well-Child Visit 0-15 months old	Well-Child Visit 0-15 months old (W15)	5Percent	0	78	100	90	25.29	640	502	-1	1		908	11	307043
Declare @W15_CurYearToDatePerc decimal(8,4),@W15_CurYearOverall  decimal(8,4),@W15_YTD_Goal_Status int,@W15_Year_Overall_Status int
Declare @AWC_CurYearToDatePerc decimal(8,4),@AWC_CurYearOverall  decimal(8,4),@AWC_YTD_Goal_Status int,@AWC_Year_Overall_Status int
Declare @W34_CurYearToDatePerc decimal(8,4),@W34_CurYearOverall  decimal(8,4),@W34_YTD_Goal_Status int,@W34_Year_Overall_Status int
Declare @AMR_CurYearToDatePerc decimal(8,4),@AMR_CurYearOverall  decimal(8,4),@AMR_YTD_Goal_Status int,@AMR_Year_Overall_Status int


select @W15_CurYearToDatePerc = 0, @AWC_CurYearToDatePerc = 0 , @W34_CurYearToDatePerc = 0 , @AMR_CurYearToDatePerc = 0

/***********  W15  ***********/
if (isnull(@W15_Complete,0) > 0)
BEGIN
	Select @W15_CurYearToDatePerc = (Convert(decimal(8,4),@W15_Complete)/Convert(decimal(8,4),@W15_Total)) * 100
END

If (@W15_CurYearToDatePerc < 75)
BEGIN
	Select @W15_YTD_Goal_Status = -1
END
else
BEGIN
	Select @W15_YTD_Goal_Status = 1
END

Select @W15_CurYearOverall = (@W15_CurYearToDatePerc )

If (@W15_CurYearOverall < 75)
BEGIN
	Select @W15_Year_Overall_Status = -1
END
else
BEGIN
	Select @W15_Year_Overall_Status = 1
END

If (isnull(@W15_PrevYear_Complete,0) > 0)
BEGIN
	Select @W15_PrevYearPerc = (@W15_PrevYear_Complete/@W15_PrevYear_Total)* 100
END



/*******   AWC  *****************/
if (isnull(@AWC_Complete,0) > 0)
BEGIN
	Select @AWC_CurYearToDatePerc = (Convert(decimal(8,4),@AWC_Complete)/Convert(decimal(8,4),@AWC_Total)) * 100
END

If (@AWC_CurYearToDatePerc < 65.56)
BEGIN
	Select @AWC_YTD_Goal_Status = -1
END
else
BEGIN
	Select @AWC_YTD_Goal_Status = 1
END

Select @AWC_CurYearOverall = (@AWC_CurYearToDatePerc )

If (@AWC_CurYearOverall < 65.56)
BEGIN
	Select @AWC_Year_Overall_Status = -1
END
else
BEGIN
	Select @AWC_Year_Overall_Status = 1
END

If (isnull(@AWC_PrevYear_Complete,0) > 0)
BEGIN
Select @AWC_PrevYearPerc = (@AWC_PrevYear_Complete/@AWC_PrevYear_Total)* 100
END


/************  W34  ************/
if (isnull(@W34_Complete,0) > 0)
BEGIN
	Select @W34_CurYearToDatePerc = (Convert(decimal(8,4),@W34_Complete)/Convert(decimal(8,4),@W34_Total)) * 100
END

If (@W34_CurYearToDatePerc < 82.69)
BEGIN
	Select @W34_YTD_Goal_Status = -1
END
else
BEGIN
	Select @W34_YTD_Goal_Status = 1
END

Select @W34_CurYearOverall = (@W34_CurYearToDatePerc ) 

If (@W34_CurYearOverall < 82.69)
BEGIN
	Select @W34_Year_Overall_Status = -1
END
else
BEGIN
	Select @W34_Year_Overall_Status = 1
END

If (isnull(@W34_PrevYear_Complete,0) > 0)
BEGIN
Select @W34_PrevYearPerc = (@W34_PrevYear_Complete/@W34_PrevYear_Total) * 100
END
/*************************/


/************  AMR  ************/
if (isnull(@AMR_Complete,0) > 0)
BEGIN
	Select @AMR_CurYearToDatePerc = (Convert(decimal(8,4),@AMR_Complete)/Convert(decimal(8,4),@AMR_Total)) * 100
END

If (@AMR_CurYearToDatePerc < 82.69)
BEGIN
	Select @AMR_YTD_Goal_Status = -1
END
else
BEGIN
	Select @AMR_YTD_Goal_Status = 1
END

Select @AMR_CurYearOverall = (@AMR_CurYearToDatePerc ) 

If (@AMR_CurYearOverall < 82.69)
BEGIN
	Select @AMR_Year_Overall_Status = -1
END
else
BEGIN
	Select @AMR_Year_Overall_Status = 1
END

If (isnull(@AMR_PrevYear_Complete,0) > 0)
BEGIN
Select @AMR_PrevYearPerc = (@AMR_PrevYear_Complete/@AMR_PrevYear_Total) * 100
END
/*************************/






INSERT #TEMP_RESULTS
SELECT 1,'W15','Well-Child Visit 0-15 months old','Well-Child Visit 0-15 months old (W15)','5Percent',isnull(@W15_PrevYearPerc,0),isnull(@W15_CurYearToDatePerc,0), isnull(@W15_CurYearOverall,0), 75,0,@W15_Total,@W15_Complete,@W15_YTD_Goal_Status,
@W15_Year_Overall_Status,'','',@CustID,0

INSERT #TEMP_RESULTS
SELECT 1,'AWC','Well-Child Visit 12-21 years old','Well-Child Visit 12-21 years old (AWC)','Other',isnull(@AWC_PrevYearPerc,0),isnull(@AWC_CurYearToDatePerc,0), isnull(@AWC_CurYearOverall,0), 65.56,0,@AWC_Total,@AWC_Complete,@AWC_YTD_Goal_Status,
@AWC_Year_Overall_Status,'','',@CustID,0

INSERT #TEMP_RESULTS
SELECT 1,'W34','Well-Child Visit 3-6 years old','Well-Child Visit 3-6 years old (W34)','5Percent',isnull(@W34_PrevYearPerc,0),isnull(@W34_CurYearToDatePerc,0), isnull(@W34_CurYearOverall,0), 82.69,0,@W34_Total,@W34_Complete,@W34_YTD_Goal_Status,
@W34_Year_Overall_Status,'','',@CustID,0

INSERT #TEMP_RESULTS
SELECT 1,'AMR','AMR','AMR','5Percent',isnull(@AMR_PrevYearPerc,0),isnull(@AMR_CurYearToDatePerc,0), isnull(@AMR_CurYearOverall,0), 82.69,0,@AMR_Total,@AMR_Complete,@AMR_YTD_Goal_Status,
@AMR_Year_Overall_Status,'','',@CustID,0



--Select @AWC_Total as AWC_Total, @AWC_Complete as AWC_Complete,@W34_Total,@W34_Complete,@W15_Total,@W15_Complete

select testID , testAbbr , testName , FullTestName , testType , PrevYearPerc , CurYearToDatePerc , CurYearOverall , GoalPerc , AvgMonthlyDifference   ,QualifyingMemCount , CompletedMemCount , YearToDateGoalStatus , CurYearOverallGoalStatus  ,PCP_NPI ,	
PCP_GroupID	 , CustID ,duration 
from #TEMP_RESULTS


	--select testID, testAbbr, testName, (testName + ' (' + testAbbr + ')') as FullTestName, testType, PrevYearPerc, CurYearToDatePerc, 
	--	case
	--	 when CurYearOverall < 0 then 0
	--	 else CurYearOverall
	--	 end as 'CurYearOverall', 
	--	GoalPerc, avgDifference as 'AvgMonthlyDifference', 
	--	QualifyingMemCount,
	--	CompletedMemCount,
	--	case
	--	when CurYearToDatePerc > GoalPerc then 1
	--	when CurYearToDatePerc = GoalPerc then 0
	--	else -1
	--	end as 'YearToDateGoalStatus',
	--	case
	--	when CurYearOverall > GoalPerc then 1
	--	when CurYearOverall = GoalPerc then 0
	--	else -1
	--	end as 'CurYearOverallGoalStatus',
	--	@PCP_NPI as PCP_NPI, 
	--	@PCP_GroupID as PCP_GroupID,
	--	@CustID as CustID, duration		
	--from #TEMP_RESULTS a
	--order by testName asc



--EXEC [dbo].[Get_HEDIS_Summary_New]   @TIN ='741662481', @CustID =11, @NPI ='' 