/****** Object:  Procedure [dbo].[Get_HPMemberByMVDID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 6/18/2014
-- Description:	<Description,,>
-- 04/05/2018		MDeLuca			Added PCCIRiskscore
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPMemberByMVDID]
	@MVDID varchar(50)	
AS
BEGIN
	SET NOCOUNT ON;
		
	SELECT	
	 li.MVDId, mpd.LastName + ', ' + mpd.FirstName AS MemberName
	,CONVERT(varchar,mpd.DOB,101) as MemberDOB
	,li.InsMemberId as InsMemberID
	,PCR.RiskScores AS PCCIRiskscore
	FROM dbo.Link_MVDID_CustID li 
	JOIN dbo.MainPersonalDetails mpd ON li.MVDId = mpd.ICENUMBER
--	LEFT JOIN dbo.ParklandPCCICOPCRisk pcr ON mpd.ICENUMBER = pcr.MVDID
	LEFT JOIN
	(
		dbo.ParklandPCCICOPCRisk pcr 
		JOIN dbo.Link_MemberId_MVD_Ins i ON pcr.MVDID = i.MVDID AND i.Cust_ID = 10
	) ON mpd.ICENUMBER = pcr.MVDID
	WHERE mpd.ICENUMBER = @MVDID
		
END