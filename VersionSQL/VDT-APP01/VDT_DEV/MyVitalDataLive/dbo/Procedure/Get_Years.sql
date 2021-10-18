/****** Object:  Procedure [dbo].[Get_Years]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 8/15/2008
-- Description:	Returns the list of years based on the passed parameter
-- Parameters: 
--		Limit: specify the list of returned number
--			Possible values: 
--			PAST - only years in the past compared to current year
--			FUTURE - only years in the future compared to current year
--			BOTH - years in the past and the future
--		Note: the list always contain the current year
-- =============================================
CREATE PROCEDURE [dbo].[Get_Years]
	@Limit varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	declare @currentYear int 
	declare @range int, -- limits the number of year in the past or future
		@index int,		-- variable holding generated years
		@max int		-- maximum year

	create table #tempYears (aYear int)	

	set @currentYear = YEAR(getdate())
	set @range = 15

	if(@Limit = 'PAST')
	begin
		set @Index = @currentYear - @range	
		set @max = @currentYear
		WHILE @Index <= @max
		BEGIN
			INSERT INTO #tempYears VALUES ( @Index )
			SET @Index = @Index + 1
		END
	end
	else if(@limit = 'FUTURE')
	begin
		set @Index = @currentYear
		set @max = @currentYear + @range
		WHILE @Index <= @max
		BEGIN
			INSERT INTO #tempYears VALUES ( @Index )
			SET @Index = @Index + 1
		END
	end
	else
	begin
		set @Index = @currentYear - @range	
		set @max = @currentYear + @range
		WHILE @Index <= @max
		BEGIN
			INSERT INTO #tempYears VALUES ( @Index )
			SET @Index = @Index + 1
		END
	end

	select aYear as YearName from #tempYears order by aYear

	drop table #tempYears
end