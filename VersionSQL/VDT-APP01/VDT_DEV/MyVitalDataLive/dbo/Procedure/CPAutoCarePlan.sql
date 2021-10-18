/****** Object:  Procedure [dbo].[CPAutoCarePlan]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Mike Grover
-- Create date: 12/30/2018
-- Description:	Auto-create careplan problems based on assessment responses
-- updated 2019-10-02 to use program type
-- =============================================
CREATE PROCEDURE [dbo].[CPAutoCarePlan] 
	@formName as varchar(50),
	@custID as varchar(10),
	@libID as int,
	@formID as bigint,
	@username as varchar(100),
	@programtype as varchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	declare @link_id as bigint
	declare @probnum as bigint
	declare @question as varchar(50)
	declare @answer as varchar(500)
	declare @answer2 as varchar(500)
	declare @doit as int
	declare @createFlag as int = 2
	declare @carePlanID as bigint
	DECLARE @ParmDefinition nvarchar(500); 
	declare @mvdid as nvarchar(50) 
	
	IF OBJECT_ID('tempdb.dbo.#shortlist', 'U') IS NOT NULL drop table #shortlist
	-- create a temp table to track links to invoke
	create table #shortlist (probnum bigint)
	
	-- get the form responses into a temp table
	IF OBJECT_ID('tempdb.dbo.##form', 'U') IS NOT NULL drop table ##form
	declare @t as nvarchar(max) = 'select hr.*, pd.Gender as gender, pd.dateofbirth as dob, dbo.fnCalAge(pd.dateofbirth) as age, pd.custid as cust_id into ##form from ' 
	+ @formName + '_form hr inner join dbo.FinalMember pd on hr.MVDID = pd.MVDID where hr.ID = ' + CAST(@formID as varchar(20))

	EXEC(@t)

	-- iterate thru the relevant link table entries and determine which links -- if any -- should be used to auto populate care plan
	set rowcount 0
	IF OBJECT_ID('tempdb.dbo.#tempRules', 'U') IS NOT NULL drop table #tempRules
	select * into #tempRules from [dbo].[CarePlanLibraryAssessmentLink]
	where [cpAssessmentID] = @formName
	and cust_id like '%' + @custID + ',%'
	and cpLibraryID = @libID
	
	set rowcount 1
	
	select @link_id = cpLinkNumber from #tempRules
	declare @doit1 as nvarchar(max)

	while @@rowcount <> 0
	begin
	    set rowcount 0
	    select @question = [cpAssessmentQuestion] from #tempRules where cpLinkNumber = @link_id
	    select @answer = [cpAssessmentResponse] from #tempRules where cpLinkNumber = @link_id
		-- determine if this link should be invoked
		select @answer2 = @question from ##form
	
		-- SET @t = N'SELECT @doit = 1 from ##form where ' + @answer2 + ' ' + @answer;   
		SET @t = N'SELECT @doit1 = CAST (case when ' + @answer2 + ' ' + @answer + ' then 1 else 0 end as int) from ##form' ;   
		SET @ParmDefinition = N'@doit1 nvarchar(max) OUTPUT';  
		
		EXECUTE sp_executesql @t, @ParmDefinition, @doit1=@doit1 OUTPUT;  
		
		-- select @doit1;
		-- print @t + ' ' + @doit1
		if (@doit1 = 1)
		begin
			select @probnum = [cpProbNum] from #tempRules where cpLinkNumber = @link_id
			insert into #shortlist values(@probnum)
		end
	
	    delete #tempRules where cpLinkNumber = @link_id
	
	    set rowcount 1
	    select @link_id = cpLinkNumber from #tempRules
	end
	set rowcount 0
	
	-- now, if we have at least one row in #shortlist, then get or create the destination careplan
	-- then loop thru #shortlist and request that problems be added to careplan
	select @doit = count(probnum) from #shortlist
	
	if (@doit > 0)
	begin
		select @mvdid = mvdid from ##form
		EXEC @carePlanID = dbo.CPGetMemberCarePlanID @custID, @mvdid, -1, @username, @createFlag, @programtype 
		
		if (@carePlanID > 0)
		begin
			set rowcount 1
	
			select @probnum = probnum from #shortlist
	
			while @@rowcount <> 0
			begin
			    set rowcount 0
				EXEC dbo.CPAddMemberCarePlanProblem @libID, @carePlanID, @username, @probnum
			    delete #shortlist where probnum = @probnum
			
			    set rowcount 1
			    select @probnum = probnum from #shortlist
			end
			set rowcount 0
		end
	end
END