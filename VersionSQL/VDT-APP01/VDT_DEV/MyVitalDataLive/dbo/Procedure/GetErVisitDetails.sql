/****** Object:  Procedure [dbo].[GetErVisitDetails]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:
-- Create date:
-- Description:
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================

CREATE PROCEDURE [dbo].[GetErVisitDetails]
As
	declare @dateRange datetime, @currentDate datetime

select @dateRange = DATEADD(month,-6,GETDATE()),
	@currentDate = GETDATE()

	
select rank() OVER (ORDER BY ID) AS ranking,MVDId, mc.InsMemberId,isnull(p.firstname,'') + isnull(' ' + p.lastname,'') as Name,
dbo.ConvertUTCtoCT(e.visitDate) AS ERVisitDate, e.FacilityName,
	e.FacilityNPI,e.VisitType,e.ChiefComplaint
from EDVisitHistory e 
	inner join dbo.Link_MVDID_CustID mc on mc.MVDId = e.ICENUMBER
	inner join HPCustomer c on c.Cust_ID = mc.Cust_ID
JOIN MainPersonalDetails p ON p.ICENUMBER = e.ICENUMBER
where
	VisitType = 'ER' 
	AND VisitDate > @dateRange
	AND Source not like '%claim%'
AND e.ICENUMBER in(
			SELECT DISTINCT s.ICENUMBER
			from dbo.MDUser u
				inner join dbo.Link_MDAccountGroup ag on u.ID = ag.MDAccountID
				inner join dbo.MDGroup g on ag.MDGroupID = g.ID
				inner join dbo.Link_MDGroupNPI n on g.ID = n.MDGroupID
				inner join dbo.MainSpecialist s on n.NPI = s.NPI
			where u.Username ='741662481'
				and s.RoleID = 1


			)
				and mc.Active = 1	

	