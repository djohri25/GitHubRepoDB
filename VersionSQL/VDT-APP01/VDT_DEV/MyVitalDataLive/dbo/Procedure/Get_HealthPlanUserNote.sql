/****** Object:  Procedure [dbo].[Get_HealthPlanUserNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 9/4/2008
-- Description:	Gets Health Plan Note about the memeber
--		And checks if there is a linking between MVD and Health Plan
--		for that user
-- =============================================
CREATE PROCEDURE [dbo].[Get_HealthPlanUserNote]
	@MVDId varchar(15),
	@IsHealthPlanMember bit output,
	@Note varchar(2000) output
as
begin
	SET NOCOUNT ON

	if exists (select * from dbo.Link_MemberId_MVD_Ins where MVDId = @MVDId)
	begin
		select @IsHealthPlanMember = 1
	end
	else
	begin
		select @IsHealthPlanMember = 0
	end

	select @Note = HealthPlanUserNote from UserAdditionalInfo where MVDID = @MVDId
end