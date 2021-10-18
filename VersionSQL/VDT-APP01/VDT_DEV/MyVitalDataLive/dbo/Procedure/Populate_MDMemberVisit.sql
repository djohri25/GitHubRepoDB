/****** Object:  Procedure [dbo].[Populate_MDMemberVisit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Populate_MDMemberVisit]
AS
BEGIN

declare @dateRange datetime, @currentDate datetime

select @dateRange = DATEADD(month,-3,GETDATE()),
	@currentDate = GETDATE()

truncate table MDMemberVisit
	
INSERT INTO MDMemberVisit
	(MVDID,InsMemberID,HPCustName,CustID,AlertDate,Facility
    ,FacilityNPI,SourceRecordID,VisitType,ChiefComplaint,EMSNote)
select e.ICENUMBER,mc.InsMemberId,c.Name,c.Cust_ID,dbo.ConvertUTCtoCT(e.visitDate), e.FacilityName,
	e.FacilityNPI,e.ID,e.VisitType,e.ChiefComplaint,''
from EDVisitHistory e 
	inner join dbo.Link_MVDID_CustID mc on mc.MVDId = e.ICENUMBER
	inner join HPCustomer c on c.Cust_ID = mc.Cust_ID
where
	VisitType = 'ER' 
	AND VisitDate > @dateRange
	AND Source not like '%claim%'
	AND ICENUMBER in
	(
		select s.ICENUMBER 
		from MDUser u
			inner join Link_MDAccountGroup ag on u.ID = ag.MDAccountID
			inner join MDGroup g on g.ID = ag.MDGroupID
			inner join Link_MDGroupNPI gn on gn.MDGroupID = g.ID
			inner join MainSpecialist s on s.NPI = gn.NPI
		where s.RoleID = 1	
	)
	and mc.Active = 1	
	--and e.ICENUMBER not in (select i.ICENUMBER from MainInsurance i where i.ICENUMBER = e.ICENUMBER and i.TerminationDate is not null and i.TerminationDate < @currentDate)
	

--select * 
--from MDUser u
--	inner join Link_MDAccountGroup ag on u.ID = ag.MDAccountID
--	inner join MDGroup g on g.ID = ag.MDGroupID
--	inner join Link_MDGroupNPI gn on gn.MDGroupID = g.ID
--	inner join MainSpecialist s on s.NPI = gn.NPI
--where s.RoleID = 1	
	
	
END	