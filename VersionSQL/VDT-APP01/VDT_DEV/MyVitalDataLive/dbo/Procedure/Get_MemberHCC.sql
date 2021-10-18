/****** Object:  Procedure [dbo].[Get_MemberHCC]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,M Grover>
-- Create date: <Create Date,,2018/02/06>
-- Description:	<Description,,resturn a list of members with HCC scores>
-- Date			Name			Comments		
-- 02/07/2018	PPetluri		As per Deep proc is taking more time, He just wanted only top 5000 records to be shown so added TOP 5000 to code.
-- =============================================
CREATE PROCEDURE [dbo].[Get_MemberHCC] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	select top 5000 j.*, l.InsMemberId from 
	(select a.MvdID,
	a.[ADJ_RiskScore] as RAScore_2014,a.[NONADJ_RiskScore] as Score_2014,a.[CCCode] as Code_2014,
	b.[ADJ_RiskScore] as RAScore_2015,b.[NONADJ_RiskScore] as Score_2015,b.[CCCode] as Code_2015,
	b.[ADJ_RiskScore] - a.[ADJ_RiskScore] as RAScore_Change,
	b.[NONADJ_RiskScore] - a.[NONADJ_RiskScore] as Score_Change,
	iif (a.[ADJ_RiskScore] > b.[ADJ_RiskScore], a.[ADJ_RiskScore], b.[ADJ_RiskScore]) as Max_Score
	from [dbo].[HCC_Member_Mapping] a
	left join [dbo].[HCC_Member_Mapping] b on b.comm_pat_id = a.comm_pat_id
	where 
	a.mbr_year = '2014'
	and b.mbr_year = '2015') j
	left join [dbo].[Link_MemberId_MVD_Ins] l on l.MVDId = j.mvdid
	order by j.mvdid
END