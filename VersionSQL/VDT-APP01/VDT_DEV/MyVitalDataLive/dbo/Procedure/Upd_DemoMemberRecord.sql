/****** Object:  Procedure [dbo].[Upd_DemoMemberRecord]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 3/8/2011
-- Description:	Update significant dates in member record
--	Don't make date greater than current date	

-- =============================================
CREATE PROCEDURE [dbo].[Upd_DemoMemberRecord]
	@MVDID varchar(15)
AS
BEGIN
	SET NOCOUNT ON;

	declare @DateIncrease int

	set @DateIncrease = 7 -- Most likely the update will be run once a week
	
	--set @MVDID = 'EB718003'
	
	DELETE from EDVisitHistory 
	where ICENUMBER = @MVDID AND FacilityName = 'Vital Data Technology'	
			
	update MainMedication 
	set RefillDate = DATEADD(DD,@DateIncrease,RefillDate)
	where ICENUMBER = @MVDID
		and RefillDate is not null
		and DATEADD(DD,@DateIncrease,RefillDate) < GETDATE()
		
	update MainCondition 
	set ReportDate = DATEADD(DD,@DateIncrease,ReportDate)
	where ICENUMBER = @MVDID
		and ReportDate is not null
		and DATEADD(DD,@DateIncrease,ReportDate) < GETDATE()	
	
	update MainSurgeries 
	set YearDate = DATEADD(DD,@DateIncrease,YearDate)
	where ICENUMBER = @MVDID
		and YearDate is not null
		and DATEADD(DD,@DateIncrease,YearDate) < GETDATE()	
	
	update EDVisitHistory 
	set VisitDate = DATEADD(DD,@DateIncrease,VisitDate)
	where ICENUMBER = @MVDID
		and VisitDate is not null
		and DATEADD(DD,@DateIncrease,VisitDate) < GETDATE()		
	
	update MainLabRequest 
	set RequestDate = DATEADD(DD,@DateIncrease,RequestDate)
	where ICENUMBER = @MVDID
		and RequestDate is not null
		and DATEADD(DD,@DateIncrease,RequestDate) < GETDATE()	
	
END