/****** Object:  Procedure [dbo].[Set_ToDoHedisSummary_Driscoll]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE procedure [dbo].[Set_ToDoHedisSummary_Driscoll]
AS
BEGIN
	SET NOCOUNT ON;

declare @RangeStart datetime

declare @npi varchar(50), @tin varchar(20), @testDueID int, @totalPatients int, @totalTestCount int, @testID int, @totalCompletedCount int, @currentDate datetime 

declare @tempNPI TABLE (NPI varchar(50),TIN varchar(20), TotalPatients int, IsProcessed bit default(0)) 

declare @tempMember table (npi varchar(50),TIN varchar(20), memberCount int)

declare @testsDue table (id int, isProcessed bit default(0))

select @RangeStart = CONVERT(datetime, CONVERT(VARCHAR(20), YEAR(GETDATE())) + '.01.01'),
	@currentDate = GETDATE()

insert into @testsDue(id)
select ID from LookupHedis

insert into @tempNPI(NPI,TIN)
select distinct NPI,TIN
from MainSpecialist s
	inner join Link_MemberId_MVD_Ins li on s.ICENUMBER = li.MVDId
where RoleID = 1 and isnull(NPI,'') <> '' and li.Cust_ID = 11

insert into @tempMember(npi,tin,memberCount)
select s.NPI,s.TIN, COUNT(*)
from MainSpecialist s
	inner join Link_MemberId_MVD_Ins li on s.ICENUMBER = li.MVDId
where RoleID = 1 and isnull(NPI,'') <> '' and li.Cust_ID = 11
	and li.Active = 1 and s.NPI in
	(
		select t.NPI from @tempNPI t
	)
group by s.NPI,s.TIN

--select * from @tempNPI
		
--select * from @tempMember		

		
while exists(select top 1 npi from @tempNPI where IsProcessed = 0)
begin
	select top 1 @npi = npi, @tin = TIN
	from @tempNPI
	where IsProcessed = 0

	declare @patientCount int
	
	select @patientCount = memberCount
	from @tempMember
	where npi = @npi

	while exists( select top 1 * from @testsDue where isProcessed= 0)
	begin
		select top 1 @testDueID = ID, @totalTestCount = 0, @totalCompletedCount = 0 from @testsDue where isProcessed= 0
	
		select @totalTestCount = COUNT(*)
		from MainToDoHEDIS h
			left join LookupTestDueStatus d on h.StatusID = d.ID
		where TestLookupID = @testDueID
			and MVDID in
			(
				select s.ICENUMBER
				from MainSpecialist s
					inner join Link_MemberId_MVD_Ins li on s.ICENUMBER = li.MVDId 
				where RoleID = 1 
					and isnull(NPI,'') <> '' 
					and li.Cust_ID = 11
					and li.Active = 1 
					and s.NPI = @npi
					and ISNULL(s.TIN,'') = 
						case ISNULL(@TIN,'')
						when '' then ISNULL(s.TIN,'')
						else ISNULL(@TIN,'')
						end
			)
			and (d.IsComplete is null or d.IsComplete = 0)			
			and h.MVDID in (select i.ICENUMBER from MainInsurance i where i.ICENUMBER = h.MVDID and (i.TerminationDate is null or i.TerminationDate > @currentDate))
				
		select @totalCompletedCount = COUNT(*)
		from MainToDoHEDIS_Done
		where TestLookupID = @testDueID
			and ArchivedDate > @RangeStart
			and MVDID in
			(
				select s.ICENUMBER
				from MainSpecialist s
					inner join Link_MemberId_MVD_Ins li on s.ICENUMBER = li.MVDId 
				where RoleID = 1 and isnull(NPI,'') <> '' and li.Cust_ID = 11
					and li.Active = 1 
					and s.NPI = @npi
					and ISNULL(s.TIN,'') = 
						case ISNULL(@TIN,'')
						when '' then ISNULL(s.TIN,'')
						else ISNULL(@TIN,'')
						end					
			)
				
		insert into MainToDoHEDIS_Summary(NPI ,TIN, TestDueID ,TotalPatients , TestDuePatientCount,testCompletedPatientCount,CustID)
		values(@npi,@tin, @testDueID,@patientCount,@totalTestCount,@totalCompletedCount,11)
		
		update @testsDue set isProcessed = 1 where id = @testDueID
	end
	
	update @testsDue set isProcessed = 0

	update @tempNPI set IsProcessed = 1
	where NPI = @npi
end

END