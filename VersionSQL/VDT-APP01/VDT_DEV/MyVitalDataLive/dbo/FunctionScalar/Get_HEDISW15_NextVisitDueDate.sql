/****** Object:  Function [dbo].[Get_HEDISW15_NextVisitDueDate]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Get_HEDISW15_NextVisitDueDate]
(
	@mvdid varchar(20)
)
RETURNS varchar(20)
AS
BEGIN
	DECLARE @testID varchar(10), @dob date, @measureDeadline date, @visitCount int, @lastVisit datetime,
		@nextVisitDueDate date, @daysUntilNextVisit int, @visitPeriodStart datetime

	SELECT @TESTID = ISNULL(ID, 0)
	FROM [dbo].[HedisSubmeasures]
	WHERE Abbreviation = 'W15'

	select @dob = dob
	from MainPersonalDetails p
	where ICENUMBER= @mvdid

	select top 1 @visitCount = visitCount, @lastVisit = LastVisitDate
	from [VD-RPT01].[_All_2015_Predictive_HEDIS].[dbo].[Final_W15Member]
	where mvdid = @mvdid --and testID = @testID 
	order by id desc

	if(@lastVisit is null)
	begin
		set @visitPeriodStart = DATEADD(day,31,@dob)
	end
	else
	begin
		set @visitPeriodStart = @lastVisit
	end
			
	select @measureDeadline = DATEADD(day,90,DATEADD(year,1,@dob))
	
	--select @daysUntilNextVisit = DATEDIFF(day,@visitPeriodStart, @measureDeadline)/(6 + 1 -@visitCount)	
	--Prevention of Divide By Zero	
	 select @daysUntilNextVisit =ISNULL(DATEDIFF(day,@visitPeriodStart, @measureDeadline)/NULLIF(6 + 1 -@visitCount,0),0)				
		
	RETURN CONVERT(varchar,DATEADD(day,@daysUntilNextVisit,@visitPeriodStart),101)
END