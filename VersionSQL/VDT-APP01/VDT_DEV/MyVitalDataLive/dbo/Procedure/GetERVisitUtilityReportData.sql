/****** Object:  Procedure [dbo].[GetERVisitUtilityReportData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:
-- Create date:
-- Description:
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================

CREATE PROCEDURE [dbo].[GetERVisitUtilityReportData]
AS

	SET NOCOUNT ON;

	declare @tempRange datetime, @VisitCountDateRange datetime, 	@DateRange int =7

	select @tempRange = '01/01/1950',
		@VisitCountDateRange = dateadd(mm,-6,getdate())


	if(@DateRange is not null AND @DateRange <> 0)
	begin
		select @tempRange = DATEADD(DD,-@DateRange,GETDATE())
	end

		select @tempRange = DATEADD(DD,-@DateRange,GETDATE())


CREATE TABLE #temp1(InsMemberId varchar(100),FirstName varchar(100),LastName varchar(100),ICENUMBER varchar(100),VisitDate date,VisitType  varchar(100),NPI  varchar(100),FacilityName varchar(100),ChiefComplaint varchar(100))
INSERT INTO #temp1
(
    InsMemberId,
    FirstName,
    LastName,
    ICENUMBER,
    VisitDate,
    VisitType,
    NPI,
    FacilityName,
    ChiefComplaint
)
SELECT  DISTINCT  InsMemberId,mpd.FirstName,mpd.LastName,ed.ICENUMBER,VisitDate,VisitType,NPI,FacilityName,ChiefComplaint 
from dbo.MainSpecialist s 
JOIN dbo.edvisithistory ed ON  ed.ICENUMBER = s.ICENUMBER
JOIN dbo.MainPersonalDetails mpd ON mpd.ICENUMBER = ed.ICENUMBER
JOIN Link_MVDID_CustID mc ON mc.MVDId = ed.ICENUMBER
where   RoleID =1 AND ed.VisitType = 'ER' AND ed.VisitDate >  @tempRange
	AND s.ICENUMBER in(
			select s.ICENUMBER
			from dbo.MDUser u
				inner join dbo.Link_MDAccountGroup ag on u.ID = ag.MDAccountID
				inner join dbo.MDGroup g on ag.MDGroupID = g.ID
				inner join dbo.Link_MDGroupNPI n on g.ID = n.MDGroupID
				inner join dbo.MainSpecialist s on n.NPI = s.NPI
			where u.Username ='742112848'
				and s.RoleID = 1
			) 
order by VisitDate DESC


--table for visit count in last 6 months (of the members we got from the above query)

CREATE TABLE #temp2(icenumber varchar(100),visitcount int)
INSERT INTO #temp2
(
    icenumber,
    visitcount
)

SELECT  ICENUMBER,count(ICENUMBER) AS last6monthvisit FROM EDVisitHistory ed WHERE ed.VisitDate > @VisitCountDateRange  AND ed.VisitType = 'ER'
and ICENUMBER in(
SELECT  DISTINCT  ed.ICENUMBER from 
dbo.MainSpecialist s 
JOIN dbo.edvisithistory ed ON  ed.ICENUMBER = s.ICENUMBER
where   RoleID =1 AND ed.VisitType = 'ER' AND ed.VisitDate >  @tempRange
	AND s.ICENUMBER in(
			select s.ICENUMBER
			from dbo.MDUser u
				inner join dbo.Link_MDAccountGroup ag on u.ID = ag.MDAccountID
				inner join dbo.MDGroup g on ag.MDGroupID = g.ID
				inner join dbo.Link_MDGroupNPI n on g.ID = n.MDGroupID
				inner join dbo.MainSpecialist s on n.NPI = s.NPI
			where u.Username ='742112848'
				and s.RoleID = 1
			) 
)			 
			GROUP BY ICENUMBER


SELECT t.*,t2.*

FROM #temp1 t JOIN #temp2 t2 ON t.ICENUMBER = t2.icenumber


DROP TABLE #temp1
DROP TABLE #temp2