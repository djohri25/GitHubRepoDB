/****** Object:  Procedure [dbo].[Get_HPMemberByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 8/26/2013
-- Description:	<Description,,>
-- 04/05/2018		MDeLuca			Added PCCIRiskscore
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPMemberByID]
	@CustID int,
	@MemberID varchar(50)	
AS
BEGIN
	SET NOCOUNT ON;

--select @CustID ='1',
--	@MemberID  = '8888888801'
		
	declare @VisitCountDateRange datetime, @ParentHPID int		

	select @ParentHPID = dbo.Get_HPParentCustomerID(@CustID),		
		@VisitCountDateRange = dateadd(mm,-6,getdate())
			
	SELECT	
	 li.MVDId, mpd.LastName + ', ' + mpd.FirstName AS MemberName
	,CONVERT(varchar,mpd.DOB,101) as MemberDOB
	,li.InsMemberId as memberID
	,(select COUNT(id) from EDVisitHistory v where v.ICENUMBER = mpd.ICENUMBER and v.VisitType = 'ER' and v.visitdate > @VisitCountDateRange) as ERVisitCount
	,(select COUNT(id) from EDVisitHistory v where v.ICENUMBER = mpd.ICENUMBER and isnull(v.facilityname,'') = '' and v.visitdate > @VisitCountDateRange) as PhysicianVisitCount
	,PCR.RiskScores AS PCCIRiskscore
	FROM dbo.Link_MVDID_CustID li 
	JOIN dbo.MainPersonalDetails mpd ON li.MVDId = mpd.ICENUMBER
	LEFT JOIN dbo.ParklandPCCICOPCRisk pcr ON mpd.ICENUMBER = pcr.MVDID
	WHERE li.InsMemberId = @MemberID
	AND Cust_ID = @ParentHPID
		
END