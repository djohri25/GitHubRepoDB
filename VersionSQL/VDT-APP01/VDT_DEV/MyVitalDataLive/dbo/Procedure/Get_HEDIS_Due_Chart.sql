/****** Object:  Procedure [dbo].[Get_HEDIS_Due_Chart]    Committed by VersionSQL https://www.versionsql.com ******/

 CREATE procedure  [dbo].[Get_HEDIS_Due_Chart] (@NPI varchar(100), @GID int, @CustID int, @TestDueID int)
 
 As  
 
 Create Table #TempNPI (NPI varchar(100))
 
 delete Test_HEDIS_CHART
 
 declare @TestCompletedPatientCount int, @TestDuePatientCount int, @TestPendingCount int
 declare @CombinedTestCompletedPatientCount int, @CombinedTestDuePatientCount int, @CombinedTestPendingCount int
 

  Select @TestCompletedPatientCount = 0, @TestDuePatientCount = 0, @TestPendingCount = 0
 Select @CombinedTestCompletedPatientCount  = 0, @CombinedTestDuePatientCount = 0 , @CombinedTestPendingCount = 0
 
 if (ISNULL(@NPI,0)) != 0 
 BEGIN 
 
	select  top 1  @TestCompletedPatientCount= TestCompletedPatientCount,
		@TestDuePatientCount = TestDuePatientCount  
		from dbo.MainToDoHEDIS_Summary where NPI = @NPI and TestDueID = @TestDueID
		order by Created desc
 
	Insert Test_HEDIS_CHART
	select 'Completed', isnull(@TestCompletedPatientCount,0)
 
	Insert Test_HEDIS_CHART
	select 'Pending', isnull(@TestPendingCount,0)
 
	Insert Test_HEDIS_CHART
	select 'Due', isnull(@TestDuePatientCount,0)
 

END
ELSE
BEGIN

	insert #TempNPI
	select NPI from dbo.Link_MDGroupNPI where MDGroupID = @GID

	while exists (select * from #TempNPI)
	begin

		select top 1 @NPI = NPI from #TempNPI

		select top 1 @CombinedTestCompletedPatientCount = @CombinedTestCompletedPatientCount + TestCompletedPatientCount,
			@CombinedTestDuePatientCount = @CombinedTestDuePatientCount + TestDuePatientCount  
			from dbo.MainToDoHEDIS_Summary where NPI = @NPI and TestDueID = @TestDueID
			order by Created desc


		Delete #TempNPI where NPI = @NPI
	end
	
	Insert Test_HEDIS_CHART
	select 'Completed', isnull(@CombinedTestCompletedPatientCount,0)
 
	Insert Test_HEDIS_CHART
	select 'Pending', isnull(@TestPendingCount,0)
 
	Insert Test_HEDIS_CHART
	select 'Due', isnull(@CombinedTestDuePatientCount,0)

END

    drop table #TempNPI

	select * from Test_HEDIS_CHART