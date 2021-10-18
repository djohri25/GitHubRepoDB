/****** Object:  Procedure [dbo].[Evaluate_HEDISPrescriptionCoverage]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/22/2013
-- Description:	Evaluate presciption coverage 
-- =============================================
CREATE PROCEDURE [dbo].[Evaluate_HEDISPrescriptionCoverage]
	@MVDID varchar(20),
	@DateRangeStart datetime,
	@DateRangeEnd datetime,
	@TestLookupID int,		-- to identify which medications qualify for the measure
	@GapCount int output,
	@LongestGap int output,
	@TotalGapLength int output
AS
BEGIN
	SET NOCOUNT ON;

	--select @MVDID = 'AA837815',
	--	@DateRangeStart = '1/1/2013',
	--	@DateRangeEnd = '1/30/2013',
	--	@TestLookupID = 16

	declare @prescription table (ID int identity(1,1), fillDate datetime, daysSupply int, PrescriberNPI varchar(20), isProcessed bit default(0))
	declare @gaps table (gap int)
	
	declare @curGap int, @rowCount int, @minFillDate datetime, @DEFAULT_DAYS_SUPPLY int,
		@id int, @fillDate datetime, @daysSupply int, @CurPrescriptionEndDate datetime, @PrevPrescriptionEndDate datetime

	set @DEFAULT_DAYS_SUPPLY = 30
	
	insert into @prescription(fillDate,daysSupply,PrescriberNPI)
	select distinct FillDate, isnull(DaysSupply, @DEFAULT_DAYS_SUPPLY), CreatedByNPI	-- TODO: verify if 30 is default
	from MainMedicationHistory
	where ICENUMBER = @MVDID
		and FillDate between @DateRangeStart and @DateRangeEnd
		and Code in (select ndc_code from Link_HEDIS_Medication where TestID = @TestLookupID)
	order by FillDate

	update @prescription set daysSupply = @DEFAULT_DAYS_SUPPLY		-- TODO: verify if 30 is default
	where daysSupply < 0

	select @rowCount = COUNT(*)
	from @prescription	
		
	--select * 
	--from @prescription
	
	select @minFillDate = MIN(fillDate)
	from @prescription

	select @curGap = DATEDIFF(DAY,@DateRangeStart,@minFillDate)

	if(@curGap > 0)
	begin
		-- Gap at begining of measurement year
		insert into @gaps(gap)
		values(@curGap)
	end

	-- overlapping prescription days must count as one toward the days supply	

	-- delete prescriptions with cover days completely overlapping by another prescription 
	while exists(select top 1 * from @prescription where isProcessed = 0)
	begin
		select top 1 @id = ID, 
			@fillDate = fillDate,
			@CurPrescriptionEndDate = DATEADD(day,daysSupply-1,fillDate)
		from @prescription 
		where isProcessed = 0
		
		delete from @prescription
		where ID <> @id
			and fillDate between @fillDate and @CurPrescriptionEndDate
			and DATEADD(day,daysSupply-1,fillDate) between @fillDate and @CurPrescriptionEndDate
		
		update @prescription set isProcessed = 1 where ID = @id
	end	
		
	update @prescription set isProcessed = 0

	if(@rowCount > 0)
	begin
		while exists(select top 1 * from @prescription where isProcessed = 0)
		begin
			select top 1 @id = ID, 
				@fillDate = fillDate,
				@daysSupply = daysSupply,
				@curGap = 0
			from @prescription 
			where isProcessed = 0
			order by FillDate
			
			if(@PrevPrescriptionEndDate is not null)
			begin
				select @curGap = DATEDIFF(DAY,@PrevPrescriptionEndDate, @fillDate) - 1
								
				-- If the the fill day is on the day after the previous prescription end day then it's 
				-- still considered continuous coverage
				if(@curGap > 0)
				begin
					-- gap in enrollment
					insert into @gaps(gap)
					values(@curGap)					
				end
			end
			
			select @PrevPrescriptionEndDate = @fillDate + @daysSupply - 1		
			
			update @prescription set isProcessed = 1 where ID = @id
		end
	end

/* Overlapping prescriptions actually counts towards covered days (don't get count as one)
	if(@rowCount > 0)
	begin
		while exists(select top 1 * from @prescription where isProcessed = 0)
		begin
			select top 1 @id = ID, 
				@fillDate = fillDate,
				@daysSupply = daysSupply,
				@curGap = 0
			from @prescription 
			where isProcessed = 0
			order by FillDate
			
			if(@PrevPrescriptionEndDate is not null)
			begin
				select @curGap = DATEDIFF(DAY,@PrevPrescriptionEndDate, @fillDate) - 1
								
				-- If the the fill day is on the day after the previous prescription end day then it's 
				-- still considered continuous coverage
				if(@curGap > 0)
				begin
					-- gap in enrollment
					insert into @gaps(gap)
					values(@curGap)					
				end
			end
			
			if(@curGap < 0)
			begin
				select @PrevPrescriptionEndDate = @PrevPrescriptionEndDate + @daysSupply		
			end
			else
			begin
				select @PrevPrescriptionEndDate = @fillDate + @daysSupply - 1		
			end
			
			update @prescription set isProcessed = 1 where ID = @id
		end
	end

*/
		
	if(@PrevPrescriptionEndDate < @DateRangeEnd)
	begin
		-- Gap at end of measurement year
		select @curGap = DATEDIFF(DAY,@PrevPrescriptionEndDate,@DateRangeEnd)	
				
		insert into @gaps(gap)
		values(@curGap)
	end	
		
	--select * from @gaps
	
	if exists(select * from @prescription)
	begin
		select @GapCount = COUNT(*), @LongestGap = isnull(MAX(gap),0), @TotalGapLength = isnull(SUM(gap),0) from @gaps
	end
	else
	begin
		select @GapCount = 1, @LongestGap = DATEDIFF(day,@dateRangeStart, @dateRangeEnd)+1, @TotalGapLength = DATEDIFF(day,@dateRangeStart, @dateRangeEnd)+1
	end
			
	--select @GapCount as '@GapCount', @LongestGap as '@LongestGap', @TotalGapLength as '@TotalGapLength'
END