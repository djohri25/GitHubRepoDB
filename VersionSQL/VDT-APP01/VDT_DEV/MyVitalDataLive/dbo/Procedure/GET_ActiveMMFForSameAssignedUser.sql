/****** Object:  Procedure [dbo].[GET_ActiveMMFForSameAssignedUser]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Raghu C
-- Create date: 08/29/19
-- Description:	Get Active MMF 
-- exec Get_ActiveMMF '16577456118885332'
-- =============================================
CREATE PROCEDURE [dbo].[GET_ActiveMMFForSameAssignedUser]
	
	@MVDID varchar(30) null,	
	@User varchar(30) null

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SELECT CaseProgram FROM ABCBS_MemberManagement_Form where SectionCompleted < 3 and len(RTRIM(CaseID)) > 0  and MVDID=@MVDID	and (q19AssignedUser = @User or q1CaseOwner = @User)

	
END