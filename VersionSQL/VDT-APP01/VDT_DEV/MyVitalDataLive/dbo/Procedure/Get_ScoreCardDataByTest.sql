/****** Object:  Procedure [dbo].[Get_ScoreCardDataByTest]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/9/2013
-- Description:	Retrieves summary percentages per Hedis test
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================
CREATE PROCEDURE [dbo].[Get_ScoreCardDataByTest]
	@TestID int,
	@PCP_GroupID int,	-- If provided then retrieve data for each PCP in the group, otherwise retrieve data for each group
	@CustID int
AS
BEGIN
	SET NOCOUNT ON;
		
	--select 
	--	@TestID = 2
	--	,@CustID = 10
	--	,@PCP_GroupID = 50
	
	declare @result table (testID int, testAbbr varchar(20), testName varchar(50),
		entityID varchar(50), entityName varchar(50),
		PrevYearPerc int, QualifyingMemCount int,
		CurYearToDatePerc int, CurYearOverall int, GoalPerc int, avgDifference decimal(8,2), isProcessed bit default(0))
	declare @monthlSummary table(id int identity(1,1), startDate datetime, monthlyPerc decimal(8,2), difFromPrev decimal(8,2))

	declare @prevYearStart datetime, @prevYearEnd datetime, @curYearStart datetime, @curDate datetime,
		@totalPatients decimal(8,2), @totalComplete decimal(8,2), @monthlyRange datetime,
		@monthlyPerc decimal(8,2), @prevMonthPerc decimal(8,2), @difFromPrev  decimal(8,2), @avgDifference  decimal(8,2), 
		@CurYearToDatePerc int, @curYearOverallPerc int,
		@hpGoal int, @prevYearPerc int, @entityID varchar(50), @entityType varchar(50), @testName varchar(50)
	
	select @prevYearStart = CONVERT(datetime, CONVERT(VARCHAR(20), YEAR(GETDATE()) - 1) + '.01.01'),
		@prevYearEnd = CONVERT(datetime, CONVERT(VARCHAR(20), YEAR(GETDATE()) - 1) + '.12.31'),
		@curYearStart = CONVERT(datetime, CONVERT(VARCHAR(20), YEAR(GETDATE())) + '.01.01'),
		@curDate = GETDATE()		
		
	--select @prevYearStart, @prevYearEnd, @curYearStart
	
	select @testName = Name
	from LookupHedis
	where ID = @TestID
	
	select @hpGoal = Goal, @prevYearPerc = PrevYearPerc
	from HPTestDueGoal
	where CustID = @CustID
	
	if(	@PCP_GroupID is null OR @PCP_GroupID = 0)
	begin	
		insert @result(entityID,entityName,GoalPerc,PrevYearPerc)
		select ID,GroupName,@hpGoal,@prevYearPerc
		from MDGroup
		where CustID_Import = @CustID and Active = 1
		
		set @entityType = 'group'
	end	
	else
	begin
		insert @result(entityID,entityName,GoalPerc,PrevYearPerc)		
		select g.NPI, dbo.fullName([Provider Last Name (Legal Name)], [Provider First Name],'') + ' (' + g.NPI + ')' as pcpFullname,@hpGoal,@prevYearPerc
		from Link_MDGroupNPI g
			inner join dbo.LookupNPI n on g.NPI = n.NPI
		where MDGroupID = @PCP_GroupID
		order by pcpFullname
		
		set @entityType = 'pcp'		
	end
		
	--select * from @result	
	
	while exists(select top 1 * from @result where isProcessed = 0)
	begin
		select 
			@entityID = entityID,
			@CurYearToDatePerc = 0,	
			@curYearOverallPerc = 0,
			@avgDifference = null,
			@totalPatients = 0,
			@totalComplete = 0
		from @result where isProcessed = 0
	
		if(ISNULL(@PCP_GroupID,0) <> 0)
		begin
		
			-- process one PCP member of the group at a time
			select top 1 @totalComplete = isnull(testCompletedPatientCount,0), 
				@totalPatients = isnull(TestDuePatientCount,0) + isnull(testCompletedPatientCount,0)
			from MainToDoHEDIS_Summary
			where NPI = @entityID
				and Created > @curYearStart
				and TestDueID = @testID
			order by ID desc			

			select @monthlyRange = @curYearStart, @prevMonthPerc = null
					
			while(@monthlyRange < @curDate)
			begin

				select @monthlyPerc = isnull(AVG(convert(decimal(8,2),testCompletedPatientCount)),0)*100/ 
					case (isnull(AVG(TestDuePatientCount),0) + isnull(AVG(testCompletedPatientCount),0))
					when 0 then 1
					else (isnull(AVG(convert(decimal(8,2),TestDuePatientCount)),0)  + isnull(AVG(convert(decimal(8,2),testCompletedPatientCount)),0))
					end
				from MainToDoHEDIS_Summary
				where NPI = @entityID
					and Created between @monthlyRange and DATEADD(day,-1, DATEADD(month,1,@monthlyRange))
					and TestDueID = @testID	
							
				if(@prevMonthPerc is not null)
				begin
					select @difFromPrev = @monthlyPerc - @prevMonthPerc
				end
																	
				insert into @monthlSummary(startDate, monthlyPerc, difFromPrev)
				values(@monthlyRange, @monthlyPerc, @difFromPrev)
						
				select @monthlyRange = DATEADD(month,1,@monthlyRange),
					@prevMonthPerc = @monthlyPerc
					
				select @monthlyPerc = null					
			end		
			
			select @avgDifference = AVG(difFromPrev)
			from @monthlSummary			
			
			delete from @monthlSummary	
		end
		else	
		begin
			-- Process one group at a time
			select @totalComplete = ISNULL(sum(convert(decimal(8,2),TestCompletedPatientCount)),0),
				@totalPatients = isnull(sum(convert(decimal(8,2),TestDuePatientCount)),0) + ISNULL(sum(convert(decimal(8,2),TestCompletedPatientCount)),0)
			from 
			(
				select distinct NPI,
					(
						select top 1 isnull(TestDuePatientCount,0)
						from MainToDoHEDIS_Summary
						where Created > @curYearStart
							and TestDueID = @testID		
							and NPI =li.NPI	
						order by ID desc
					) as TestDuePatientCount,
					(
						select top 1 isnull(testCompletedPatientCount,0)
						from MainToDoHEDIS_Summary
						where Created > @curYearStart
							and TestDueID = @testID		
							and NPI =li.NPI	
						order by ID desc
					) as TestCompletedPatientCount
				from Link_MDGroupNPI li
				where MDGroupID = @entityID
			) t	
				
			select @monthlyRange = @curYearStart, @prevMonthPerc = null
					
			while(@monthlyRange < @curDate)
			begin
				select @monthlyPerc = isnull(AVG(convert(decimal(8,2),testCompletedPatientCount)),0)*100/ 
					case (isnull(AVG(TestDuePatientCount),0) + isnull(AVG(testCompletedPatientCount),0))
					when 0 then 1
					else (isnull(AVG(convert(decimal(8,2),TestDuePatientCount)),0) + isnull(AVG(convert(decimal(8,2),testCompletedPatientCount)),0))
					end
				from MainToDoHEDIS_Summary
				where Created between @monthlyRange and DATEADD(day,-1, DATEADD(month,1,@monthlyRange))
					and TestDueID = @testID	
					and NPI in
					(
						select distinct NPI from Link_MDGroupNPI 
						where MDGroupID = @entityID
					)					
																						
				if(@prevMonthPerc is not null)
				begin
					select @difFromPrev = @monthlyPerc - @prevMonthPerc
				end
																	
				insert into @monthlSummary(startDate, monthlyPerc, difFromPrev)
				values(@monthlyRange, @monthlyPerc, @difFromPrev)
			
				select @monthlyRange = DATEADD(month,1,@monthlyRange),
					@prevMonthPerc = @monthlyPerc
					
				select @monthlyPerc = null										
			end		

			select @avgDifference = AVG(difFromPrev)
			from @monthlSummary
			
			delete from @monthlSummary	
				
		end
	
		select @CurYearToDatePerc = @totalComplete * 100/
			case @totalPatients
			when 0 then 1
			else @totalPatients
			end

		if((isnull(@CurYearToDatePerc,0) + (12-MONTH(@curDate))*isnull(@avgDifference,0)) < 100)
		begin
			select @curYearOverallPerc = isnull(@CurYearToDatePerc,0) + (12-MONTH(@curDate))*isnull(@avgDifference,0)
		end
		else
		begin
			select @curYearOverallPerc = 100
		end
						
		update @result 
		set isProcessed = 1,
			CurYearToDatePerc = @CurYearToDatePerc,	
			CurYearOverall = @curYearOverallPerc,
			avgDifference = @avgDifference,
			QualifyingMemCount = @totalPatients
		where entityID = @entityID
	end
	
	select entityID, entityName, @entityType as 'entityType', PrevYearPerc, CurYearToDatePerc, 
		@TestID as TestID, @testName as TestName,
		case
		when CurYearOverall < 0 then 0
		else CurYearOverall
		end as 'CurYearOverall', 
		GoalPerc, avgDifference as 'AvgMonthlyDifference', 
		case
		when CurYearToDatePerc > GoalPerc then 1
		when CurYearToDatePerc = GoalPerc then 0
		else -1
		end as 'YearToDateGoalStatus',
		case
		when CurYearOverall > GoalPerc then 1
		when CurYearOverall = GoalPerc then 0
		else -1
		end as 'CurYearOverallGoalStatus',
		QualifyingMemCount,
		@PCP_GroupID as PCP_GroupID,
		@CustID as CustID		
	from @result 
	order by entityName
	
END