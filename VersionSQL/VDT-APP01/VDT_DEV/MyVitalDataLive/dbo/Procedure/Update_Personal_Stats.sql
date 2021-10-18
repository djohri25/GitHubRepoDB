/****** Object:  Procedure [dbo].[Update_Personal_Stats]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Mike Grover
-- Create date: 2019-08-11
-- Description:	generate sumamry totals into MainPersonalStats table
-- =============================================
CREATE PROCEDURE [dbo].[Update_Personal_Stats] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--update [MyVitalDataUAT].[Rules].[MainPersonalStats]
--set Rolling12MonthAllClaimCost = (select sum(H.TotalPaidAmount)
--from FinalClaimsHeader H
--where H.StatementFromDate between DATEADD(year,-1,GetDate()) and GetDate()
--and H.MVDID = [Rules].[MainPersonalStats].MVDID)

--update [MyVitalDataUAT].[Rules].[MainPersonalStats]
--set Rolling12MonthRxClaimCost = (select sum(R.PaidAmount)
--from FinalRX R
--where R.ServiceDate between DATEADD(year,-1,GetDate()) and GetDate()
--and R.MVDID = [Rules].[MainPersonalStats].MVDID)

--update [MyVitalDataUAT].[Rules].[MainPersonalStats]
--set YTDAllClaimCost = (select sum(H.TotalPaidAmount)
--from FinalClaimsHeader H
--where H.StatementFromDate between DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) and GetDate()
--and H.MVDID = [Rules].[MainPersonalStats].MVDID)

--update [MyVitalDataUAT].[Rules].[MainPersonalStats]
--set YTDRxClaimCost = (select sum(R.PaidAmount)
--from FinalRX R
--where R.ServiceDate between DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) and GetDate()
--and R.MVDID = [Rules].[MainPersonalStats].MVDID)

MERGE [Rules].[MainPersonalStats] as TARGET
USING (

select 
	MVDID, 
	SUM(AcuteVisit) as AcuteVisit,
	SUM(ERVisit) as ERVisit,
	MAX(LastERVisit) as LastERVisit,
	SUM(NFVisit) as NFVisit,
	SUM(BHVisit) as BHVisit,
	SUM(RehabVisit) as RehabVisit,
	SUM(PhysicianVisit) as PhysicianVisit,
	MAX(LastPhysicianVisit) as LastPhysicianVisit,
	SUM(YTDPaidAmount) as YTDPaidAmount,
	SUM(Rolling12PaidAmount) as Rolling12PaidAmount
from (
select
	MVDID, 
	0 as AcuteVisit,
	0 as ERVisit,
	null as LastERVisit,
	0 as NFVisit,
	0 as BHVisit,
	0 as RehabVisit,
	0 as PhysicianVisit,
	null as LastPhysicianVisit,
	SUM(YTDPaidAmount) as YTDPaidAmount,
	SUM(Rolling12PaidAmount) as Rolling12PaidAmount
from (
select MVDID, 
	case when DATEPART(YEAR,StatementFromDate) = DATEPART(YEAR,GETDATE()) then [TotalPaidAmount] else 0 end as YTDPaidAmount,
	case when StatementFromDate >= DATEADD(YEAR,-1,GETDATE()) then [TotalPaidAmount] else 0 end as Rolling12PaidAmount
FROM [dbo].[FinalClaimsHeader]
where StatementFromDate >= DATEADD(YEAR,-1,GETDATE())
) V
group by MVDID
UNION
select 
	MVDID, 
	SUM(AcuteVisit) as AcuteVisit,
	SUM(ERVisit) as ERVisit,
	MAX(ERVisitDate) as LastERVisit,
	SUM(NFVisit) as NFVisit,
	SUM(BHVisit) as BHVisit,
	SUM(RehabVisit) as RehabVisit,
	SUM(PhysicianVisit) as PhysicianVisit,
	MAX(PhysicianVisitDate) as LastPhysicianVisit,
	0 as YTDPaidAmount,
	0 as Rolling12PaidAmount
from (
select MVDID, 
case when POS = 21 and IsHospitalAdmit = 1 then 1 else 0 end as AcuteVisit,
case when VisitType = 'ER' then 1 else 0 end as ERVisit, --POS = 23 then 1 else 0 end as ERVisit,
case when VisitType = 'ER' then VisitDate else null end as ERVisitDate,-- POS = 23 then VisitDate else null end as ERVisitDate,
case when POS in (31,32,33,34) then 1 else 0 end as NFVisit,
case when POS between 51 and 59 then 1 else 0 end as BHVisit,
case when POS = 61 then 1 else 0 end as RehabVisit,
case when POS not in (23,31,32,33,34,51,52,53,54,55,56,57,58,59,61) OR (POS = 21 and IsHospitalAdmit = 0) then 1 else 0 end as PhysicianVisit,
case when POS not in (23,31,32,33,34,51,52,53,54,55,56,57,58,59,61) OR (POS = 21 and IsHospitalAdmit = 0) then VisitDate else null end as PhysicianVisitDate
from [dbo].[ComputedMemberEncounterHistory]
where VisitDate > DateAdd(YEAR,-1,GetDate())
) V1
group by MVDID
) Z
group by MVDID

) as SOURCE
ON TARGET.MVDID = SOURCE.MVDID
WHEN MATCHED THEN
UPDATE SET 
	TARGET.[Rolling12MonthERVisits] = SOURCE.ErVisit, 
	TARGET.[Rolling12MonthPhysicianVisits] = SOURCE.PhysicianVisit,
	TARGET.[Rolling12MonthAcuteVisits] = SOURCE.AcuteVisit,
	TARGET.[Rolling12MonthBHVisits] = SOURCE.BHVisit,
	TARGET.[Rolling12MonthNFVisits] = SOURCE.NFVisit,
	TARGET.[Rolling12MonthRehabVisits] = SOURCE.RehabVisit,
	TARGET.[LastERVisit] = SOURCE.LastERVisit,
	TARGET.[LastPhysicianVisit] = SOURCE.LastPhysicianVisit,
	TARGET.[Rolling12MonthAllClaimCost]= SOURCE.Rolling12PaidAmount, 
	TARGET.[YTDAllClaimCost] = SOURCE.YTDPaidAmount,
	TARGET.[ModifyDate] = GetDate()
WHEN NOT MATCHED BY TARGET THEN
INSERT (CUST_ID,
		MVDID,
		[Rolling12MonthERVisits],
		[Rolling12MonthPhysicianVisits],
		[Rolling12MonthAcuteVisits],
		[Rolling12MonthBHVisits],
		[Rolling12MonthNFVisits],
		[Rolling12MonthRehabVisits],
		[LastERVisit],
		[LastPhysicianVisit],
		[Rolling12MonthAllClaimCost],
		[YTDAllClaimCost],
		[CreationDate])
	VALUES (16,
			SOURCE.MVDID, 
			SOURCE.ErVisit,
			SOURCE.PhysicianVisit,
			SOURCE.AcuteVisit,
			SOURCE.BHVisit,
			SOURCE.NFVisit,
			SOURCE.RehabVisit,
			SOURCE.LastERVisit,
			SOURCE.LastPhysicianVisit,
			SOURCE.Rolling12PaidAmount,
			SOURCE.YTDPaidAmount,
			GetDate())
WHEN NOT MATCHED BY SOURCE THEN
DELETE;


END