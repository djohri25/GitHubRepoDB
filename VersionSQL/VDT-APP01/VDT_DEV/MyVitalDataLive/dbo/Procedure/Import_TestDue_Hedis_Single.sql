/****** Object:  Procedure [dbo].[Import_TestDue_Hedis_Single]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 4/18/2012
-- Description:	Import single Hedis record
-- =============================================
CREATE PROCEDURE [dbo].[Import_TestDue_Hedis_Single]
	@RecordID int,						
	@MemberID varchar(50),
	@W15 varchar(50),
	@W34 varchar(50),
	@AWC varchar(50),
	@LeadTesting varchar(50),
	@BreastCancerScreening varchar(50),
	@CervicalCancerScreening varchar(50), 
    @ColorectalCancerScreening varchar(50),
    @Source varchar(50),
	@ImportResult int out			-- 0 - success, -1 - failure or unknown item found, -2 - item listed on "ignore list"
AS
BEGIN
	SET NOCOUNT ON;

	select @ImportResult = -1

	--select 
	--	@RecordID = 5445,						
	--	@MemberID = '525485924',
	--	@W15 = null,
	--	@W34 = 'N',
	--	@AWC = null
	
	if(@W15 is not null AND (@W15 = 'N' OR @W15 = 'NO'))
	begin
		EXEC Set_ToDoHedis @InsMemberID = @MemberID, @TestAbbreviation = 'W15', @Source = @source
	end
	
	if(@W34 is not null AND (@W34 = 'N' OR @W34 = 'NO'))
	begin
		EXEC Set_ToDoHedis @InsMemberID = @MemberID, @TestAbbreviation = 'W34', @Source = @source
	end

	if(@AWC is not null AND (@AWC = 'N' OR @AWC = 'NO'))
	begin
		EXEC Set_ToDoHedis @InsMemberID = @MemberID, @TestAbbreviation = 'AWC', @Source = @source
	end
	
	if(@LeadTesting is not null AND (@LeadTesting = 'N' OR @LeadTesting = 'NO'))
	begin
		EXEC Set_ToDoHedis @InsMemberID = @MemberID, @TestAbbreviation = 'LSC', @Source = @source
	end
	
	if(@BreastCancerScreening is not null AND (@BreastCancerScreening = 'N' OR @BreastCancerScreening = 'NO'))
	begin
		EXEC Set_ToDoHedis @InsMemberID = @MemberID, @TestAbbreviation = 'BCS', @Source = @source
	end

	if(@CervicalCancerScreening is not null AND (@CervicalCancerScreening = 'N' OR @CervicalCancerScreening = 'NO'))
	begin
		EXEC Set_ToDoHedis @InsMemberID = @MemberID, @TestAbbreviation = 'CCS', @Source = @source
	end

	if(@ColorectalCancerScreening is not null AND (@ColorectalCancerScreening = 'N' OR @ColorectalCancerScreening = 'NO'))
	begin
		EXEC Set_ToDoHedis @InsMemberID = @MemberID, @TestAbbreviation = 'COL', @Source = @source
	end
	
	set @ImportResult = 0
END