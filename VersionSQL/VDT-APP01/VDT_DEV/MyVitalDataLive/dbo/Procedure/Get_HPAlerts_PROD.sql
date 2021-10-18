/****** Object:  Procedure [dbo].[Get_HPAlerts_PROD]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_HPAlerts] (
--Declare
	 --@UserName varchar(500) = null 
	--,
@UserID varchar(50)
	,@DateRange int =null
	,@Customer varchar(50)
	,@IsCompleted bit = null
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
select Group_ID from Link_hpalertgroupAgent where Agent_ID=@UserID



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
cast(ROW_NUMBER() OVER(ORDER BY calc.memberid) as int) as ID,
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
calc.memberid as MemberID, 
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
calc.LastName as LastName, 
calc.FirstName as FirstName,	
null as 	PCCIRiskscore	,
null as 	HasAsthma	,
null as 	HasDiabetes	,
		isnull(calc.LOB,'') as LOB ,
null as 	HedisDue	,
	    calc.LastName + ', ' + calc.FirstName AS MemberName,
		calc.MVDID as MVDId,
	ISNULL(CONVERT(varchar,calc.dob,101),'') AS MemberDOB
		--main.DateOfBirth as MemberDOB,
		,Rg.RuleName as Text 
		--ins.PlanGroup as [Group],
		--ins.Region
		--,Calc.CaseID as CaseID
		--,isnull(calc.OpenCaseCount,0)           as NumOpenCases
		--,isnull(Calc.OpenTaskCount,0)            as NumOpenTasks
		--,isnull(Calc.CaseOwner,0)			 as CaseOwner
		--,isnull(Calc.CaseProgram,0)			 as CaseProgram
		--,isnull(Calc.MemberOwner,0)			 as MemberOwner
		from #RuleNameMVDID RG
		inner join (select * from ComputedCareQueue where HealthPlanEmployeeFlag =0) calc 
		on calc.MVDID=rg.MVDID
			



	end 