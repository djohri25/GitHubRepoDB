/****** Object:  Function [dbo].[Get_HedisTestDueByMember]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 6/9/2014
-- Description:	Returns comma delimited list of hedis test abbreviations due by member
-- =============================================
CREATE FUNCTION [dbo].[Get_HedisTestDueByMember]
(
	@MVDID varchar(20)
)
RETURNS varchar(max)
AS
BEGIN
	declare @testList varchar(max)

	set @testList = ''

	select @testList = @testList + lh.name + ',' 
	from [Final_HEDIS_Member] h
		inner join HEDIS_Results.dbo.LookupHedis lh on h.TestID = lh.ID
	where MVDID = @MVDID
		and lh.id in
		(
			 select TestDueID from dbo.HPTestDueGoal where DRLink_Active = 1
		)
		
	if(LEN(@testList) > 0)
	begin
		set @testList = SUBSTRING(@testList,0,len(@testList))
	end

	RETURN @testList

END