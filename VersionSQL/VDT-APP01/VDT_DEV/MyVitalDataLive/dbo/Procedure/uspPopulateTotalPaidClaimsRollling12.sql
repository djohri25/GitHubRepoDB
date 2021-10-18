/****** Object:  Procedure [dbo].[uspPopulateTotalPaidClaimsRollling12]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[uspPopulateTotalPaidClaimsRollling12] @CustID int, @RunDate date = NULL

as
begin
-- =============================================
-- Author:		John Patrick "JP" Gregorio
-- Create date: 08/06/2019
-- Description: Calculate Sum of all of Medical and RX Claim's TotalPaidAmount per member for the previous 12 months
-- Exec dbo.uspPopulateTotalPaidClaimsRollling12 16, NULL
-- =============================================

Set NoCount ON


Declare @MonthToMeasure date =GetDate()

If @RunDate is not NULL
Begin
	Set @MonthToMeasure = @RunDate
End

Declare @MeasureMonthStart date = DATEADD(d,1,(EOMONTH(DATEADD(m,-13,@MonthToMeasure)))) 
Declare @MeasureMonthEnd date =  EOMONTH(DATEADD(m,-1,@MonthToMeasure)) 
Declare @MonthID varchar(6)= Left(Convert(varchar(10),EOMONTH(@MonthToMeasure) ,112),6)

Drop Table if Exists #Check
Select MemberID, MVDID, TotalPaidAmount, StatementFromDate
Into #Check
From FinalClaimsHeader
Where StatementFromDate between @MeasureMonthStart and @MeasureMonthEnd
and CustID = @CustID and ClaimStatus = '1'
Union
Select MemberID, MVDID, PaidAmount, ServiceDate
From FinalRX
Where ServiceDate between @MeasureMonthStart and @MeasureMonthEnd
and CustID = @CustID and ClaimStatus = '1'

Drop Table If Exists #Sum
Select MVDID,  MemberID, sum(TotalPaidAmount) as TotalPaidAmount_Last12Months, @MeasureMonthStart as MeasureMonthStart, @MeasureMonthEnd as MeasureMonthEnd, @MonthID as MonthID
Into #Sum
From #Check
Group by MVDID,  MemberID
Order by sum(totalpaidamount) desc

If Exists (Select * From [dbo].[ComputedMemberTotalPaidClaimsRollling12] Where CustID = @CustID and MonthID = @MonthID)
Begin
Delete From [dbo].[ComputedMemberTotalPaidClaimsRollling12] Where CustID = @CustID and MonthID = @MonthID
End

Insert Into [dbo].[ComputedMemberTotalPaidClaimsRollling12]
(MVDID, MemberID, LOB, PlanGroup, MonthID, MeasureMonthStart,MeasureMonthEnd, TotalPaidAmount, CustID, CreateDate)
Select a.MVDID, a.MemberID, LOB, PlanGroup, MonthID, MeasureMonthStart, MeasureMonthEnd, TotalPaidAmount_Last12Months, @CustID, GETUTCDATE()
From #Sum a inner join ComputedCareQueue b on a.mvdid = b.MVDID
Order by TotalPaidAmount_Last12Months desc

-- Company and LOB Based Threshold
Update A
Set a.HighDollarClaim =  Case When a.TotalPaidAmount >= b.HighDollarThreshold Then 1 Else 0 End
From ComputedMemberTotalPaidClaimsRollling12 a Inner Join LookUpHighDollarClaimThreshold b on a.PlanGroup = b.PlanGroup and a.LOB = b.LOB and a.CustID = b.CustID
Where a.MonthID = @MonthID and a.CustID = @CustID and a.HighDollarClaim is NULL

-- Company Based Threshold
Update A
Set a.HighDollarClaim =  Case When a.TotalPaidAmount >= b.HighDollarThreshold Then 1 Else 0 End
From ComputedMemberTotalPaidClaimsRollling12 a Inner Join LookUpHighDollarClaimThreshold b on a.PlanGroup = b.PlanGroup and a.CustID = b.CustID
Where a.MonthID = @MonthID and a.CustID = @CustID and b.LOB = 'ALL' and a.HighDollarClaim is NULL

-- LOB Based Threshold
Update A
Set a.HighDollarClaim =  Case When a.TotalPaidAmount >= b.HighDollarThreshold Then 1 Else 0 End
From ComputedMemberTotalPaidClaimsRollling12 a Inner Join LookUpHighDollarClaimThreshold b on a.LOB = b.LOB and a.CustID = b.CustID
Where a.MonthID = @MonthID and a.CustID = @CustID and b.PlanGroup = 'ALL' and a.HighDollarClaim is NULL 

-- All others
Update A
Set a.HighDollarClaim =  Case When a.TotalPaidAmount >= b.HighDollarThreshold Then 1 Else 0 End
From ComputedMemberTotalPaidClaimsRollling12 a Inner Join LookUpHighDollarClaimThreshold b on a.CustID = b.CustID
Where a.MonthID = @MonthID and a.CustID = @CustID and  b.LOB = 'ALL' and b.PlanGroup = 'ALL' and a.HighDollarClaim is NULL 
end