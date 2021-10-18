/****** Object:  Procedure [dbo].[Set_ToDoHedis]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 4/19/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_ToDoHedis]
	@InsMemberID varchar(50),
	@TestAbbreviation varchar(20),
	@Source varchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @testLookupID int, @testDescription varchar(100)

	select @testLookupID = ID, @testDescription = Name + ISNULL(' (' + Abbreviation + ')','')
	from LookupHedis
	where abbreviation = @TestAbbreviation
	
	if not exists(select id from dbo.MainToDoHEDIS 
		where MemberID = @InsMemberID and TestLookupID is not null and TestLookupID = @testLookupID)
	begin
		insert MainToDoHEDIS(MemberID,Major,minor,Source, TestLookupID)
		values (@InsMemberID, @testDescription,'',@source, @testLookupID)
	end

END