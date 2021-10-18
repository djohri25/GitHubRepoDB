/****** Object:  Procedure [dbo].[Evaluate_HEDISEnrollmentCoverage]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/22/2013
-- Description:	Evaluate enrollment coverage 
-- =============================================
CREATE PROCEDURE [dbo].[Evaluate_HEDISEnrollmentCoverage]
	@MVDID varchar(20),
	@DateRangeStart datetime,
	@DateRangeEnd datetime,
	@AnchorDate date,
	@GapCount int output,
	@LongestGap int output,
	@AnchorDateCovered bit output
AS
BEGIN
	SET NOCOUNT ON;

	--select @MVDID = 'JM444504',
	--	@DateRangeStart = '1/1/2012',
	--	@DateRangeEnd = '12/31/2012',
	--	@AnchorDate = '12/31/2012'

	declare @enrollments table (ID int identity(1,1), effectiveDate datetime, terminationDate datetime, isProcessed bit default(0))
	declare @gaps table (gap int)
	
	declare @minEffectiveDate datetime, @maxTerminationDate datetime, @curGap int, @rowCount int,
		@id int, @curEffectiveDate datetime, @curTerminationDate datetime, @prevTerminationDate datetime

	insert into @enrollments(effectiveDate,terminationDate)
	select distinct EffectiveDate, isnull(TerminationDate, DATEADD(Year,10,getdate()))
	from MainInsurance_History
	where ICENUMBER = @MVDID
		and (TerminationDate is null or TerminationDate >= @DateRangeStart)
		and EffectiveDate <= @DateRangeEnd
	order by EffectiveDate

	-- delete enrollements with dates completely covered by another enrollement (one policy completely overlaps the other policy)
	while exists(select top 1 * from @enrollments where isProcessed = 0)
	begin
		select top 1 @id = ID, 
			@curEffectiveDate = effectiveDate,
			@curTerminationDate = terminationDate 
		from @enrollments 
		where isProcessed = 0
		
		delete from @enrollments
		where ID <> @id
			and effectiveDate between @curEffectiveDate and @curTerminationDate
			and terminationDate between @curEffectiveDate and @curTerminationDate
		
		update @enrollments set isProcessed = 1 where ID = @id
	end	
	
	update @enrollments set isProcessed = 0
	
	select @rowCount = COUNT(*)
	from @enrollments	
		
	--select * 
	--from @enrollments
	
	select @minEffectiveDate = MIN(effectiveDate),
		@maxTerminationDate = MAX(terminationDate)
	from @enrollments
	
	--select @minEffectiveDate as '@minEffectiveDate', @maxTerminationDate as '@maxTerminationDate'
	
	select @curGap = DATEDIFF(DAY,@DateRangeStart,@minEffectiveDate)

	if(@curGap > 0)
	begin
		-- Gap at begining of measurement year
		insert into @gaps(gap)
		values(@curGap)
	end
	
	select @curGap = DATEDIFF(DAY,@maxTerminationDate,@DateRangeEnd)

	if(@curGap > 0)
	begin
		-- Gap at end of measurement year
		insert into @gaps(gap)
		values(@curGap)
	end	
	
	if(@rowCount > 1)
	begin
		while exists(select top 1 * from @enrollments where isProcessed = 0)
		begin
			select top 1 @id = ID, 
				@curEffectiveDate = effectiveDate,
				@curTerminationDate = terminationDate 
			from @enrollments 
			where isProcessed = 0
			order by effectiveDate
			
			if(@prevTerminationDate is not null)
			begin
				select @curGap = DATEDIFF(DAY,@prevTerminationDate,@curEffectiveDate)
				
				-- If the the effective day is on the day after the termination day then it's 
				-- still considered continuous enrollement
				if(@curGap > 1)
				begin
					-- gap in enrollment
					insert into @gaps(gap)
					values(@curGap)					
				end
			end
			
			select @prevTerminationDate = @curTerminationDate
			
			update @enrollments set isProcessed = 1 where ID = @id
		end
	end
	
	if exists( select * from @enrollments where effectiveDate <= @AnchorDate and terminationDate >= @AnchorDate)
	begin
		set @AnchorDateCovered = 1
	end
	else
	begin
		set @AnchorDateCovered = 0
	end
	
	--select * from @gaps
	
	if exists(select * from @enrollments)
	begin
		select @GapCount = COUNT(*), @LongestGap = MAX(gap) from @gaps
	end
	else
	begin
		select @GapCount = 1, @LongestGap = 365, @AnchorDateCovered = 0
	end
	--select @GapCount as '@GapCount', @LongestGap as '@LongestGap', @AnchorDateCovered as '@AnchorDateCovered'
END