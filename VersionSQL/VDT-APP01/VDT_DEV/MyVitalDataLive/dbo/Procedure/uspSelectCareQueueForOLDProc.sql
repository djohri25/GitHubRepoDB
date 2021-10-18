/****** Object:  Procedure [dbo].[uspSelectCareQueueForOLDProc]    Committed by VersionSQL https://www.versionsql.com ******/

Create PROCEDURE [dbo].[uspSelectCareQueueForOLDProc] (
--Declare
	 --@UserName varchar(500) = null 
	--,
@UserID varchar(50)
	,@DateRange int
	,@Customer varchar(50)
	,@IsCompleted bit
	,@AfterHoursFilter bit = NULL
	,@RecipientID varchar(50) = NULL
	,@CopcFacilityID varchar(50) = NULL
	,@CopcPCP_NPI varchar(50) = NULL
	,@MemberID VARCHAR(20) = NULL
)


as begin 

Set nocount on;

--Create Temp table 
drop table if exists #UserGroup
drop table if exists #RuleGroup
Drop table if exists #RuleNameMVDID
Drop table if exists #RuleGroupMVDID


Create table #UserGroup (Id int identity(1,1), GroupID int)
Create table #RuleGroup (Id int identity(1,1), RuleID int, GroupID int, RuleName varchar(100))
Create table #RuleGroupMVDID (Id int identity(1,1), RuleID int, GroupID int, RuleName varchar(100), MVDID varchar(30) )
Create table #RuleNameMVDID (MVDID varchar(100), RuleName varchar(max))

--Insert userGrpID into the temp table
Insert into #UserGroup (GroupID)
select Group_ID from Link_hpalertgroupAgent where Agent_ID=@UserID--'E16D8FA5-0365-4794-856D-2D3C90DA83A7'

 --'69ABBD2B-ED82-4D75-B2B9-4F9091F41322


INSERT into #RuleGroup (RuleID, GroupID, RuleName )
select rg.Rule_ID as RuleID , rg.AlertGroup_ID as GroupID, WFR.Name as RuleName   from Link_HPRuleAlertGroup RG
inner join #UserGroup UG
on ug.GroupID= RG.AlertGroup_ID
Inner join (select * from hpworkflowrule where Cust_ID=@Customer ) WFR
on wfr.Rule_ID=RG.Rule_ID
group by rg.Rule_ID,rg.AlertGroup_ID, WFR.Name


insert into #RuleGroupMVDID (RuleID , GroupID , RuleName, MVDID)
select RG.RuleID,	RG.GroupID,	RG.RuleName , hp.MVDID
from #RuleGroup RG
inner join 
(select MVDID, TriggerID, TriggerType, AgentID 
from HPAlert where TriggerType in ('Rule','workflow') and RecipientCustID=@Customer
group by MVDID, TriggerID, TriggerType, AgentID) HP
on hp.TriggerID=rg.RuleID and (Cast(rg.GroupID as varchar(500))=hp.AgentID 
or hp.AgentID=@UserID)



Insert into #RuleNameMVDID (MVDID,RuleName)
SELECT  E.MVDID, STUFF((SELECT  ',' + isnull(RuleName,'')
            FROM #RuleGroupMVDID EE
            WHERE  EE.mvdid=E.mvdid
            ORDER BY mvdid
        FOR XML PATH('')), 1, 1, '') AS listStr
FROM #RuleGroupMVDID E
GROUP BY E.mvdid


		select 
		--task.Id,
		--care.Id,
RowNum =  ROW_NUMBER() OVER(ORDER BY Main.memberid),
		null as ID,
null as AgentID,
null as AlertDate,
null as Facility,
null as Customer,
null as StatusID, 
null as DateCreated, 
null as StatusName,
null as IsCompleted,
null as RowOwner,
null as RecipientType, 
null as ModifiedBy, 
null as 	ChiefComplaint	,
null as 	EMSNote	,
Rg.RuleName as 	TriggerName	,
main.memberid as MemberID, 
null as 	DateModified	,
null as 	ERVisitCount	,
null as 	PhysicianVisitCount	,
null as 	DischargeDisposition	,
null as 	LockedBy	,
null as 	IsHighER	,
null as 	ERVisitDescription	,
null as 	IsHighRX	,
null as 	RXAvgCost	,
null as 	RXDescription	,
null as 	IsHighUtil	,
null as 	HighUtilCost	,
null as 	HighUtilDescription	,
null as 	HCCScore	,
null as 	ElixhauserScore	,
null as 	CharlsonScore	,
null as 	NotesCount	,
main.MemberLastName as MemberLastName, 
main.MemberFirstName as MemberFirstName,	
null as 	PCCIRiskscore	,
null as 	HasAsthma	,
null as 	HasDiabetes	,
		isnull(ins.LOB,'') as LOB ,
null as 	HedisDue	,
	    main.MemberLastName + ', ' + main.MemberFirstName AS MemberName,
		main.MVDID as MVDId,	
		main.DateOfBirth as MemberDOB,
		Rg.RuleName as Text 
		--ins.PlanGroup as [Group],
		--ins.Region
		--,Calc.CaseID as CaseID
		--,isnull(calc.OpenCaseCount,0)           as NumOpenCases
		--,isnull(Calc.OpenTaskCount,0)            as NumOpenTasks
		--,isnull(Calc.CaseOwner,0)			 as CaseOwner
		--,isnull(Calc.CaseProgram,0)			 as CaseProgram
		--,isnull(Calc.MemberOwner,0)			 as MemberOwner
		from #RuleNameMVDID RG
		inner join  ( select 
							MemberID, 
							MVDID,	
							MemberFirstName,	
							MemberLastName, 
							DateOfBirth from [dbo].finalmember 
							where HealthPlanEmployeeFlag=0) main
				on main.MVDID=RG.MVDID
		inner join ComputedCareQueue calc 
		on calc.MVDID=rg.MVDID
			Left join (select Mvdid, LOB, PlanGroup, grp_name as PlanGroupName, CountyName as Region from [dbo].FinalEligibility FE
						inner join [LookupGroup] LG
						on fe.PlanGroup=LG.grp_key
						where HealthPlanEmployeeFlag=0) ins 
				on ins.MVDID= RG.MVDID



	end 