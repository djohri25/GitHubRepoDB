/****** Object:  Procedure [dbo].[Upd_HealthPlanUserNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 9/4/2008
-- Description:	Creates/Updates note provided by Health Plan 
--		about the member
-- =============================================
CREATE PROCEDURE [dbo].[Upd_HealthPlanUserNote]
	@MVDId varchar(15),
	@Note varchar(2000)	
as
begin
	SET NOCOUNT ON

	if exists (select * from UserAdditionalInfo where MVDID = @MVDId)
	begin
		update UserAdditionalInfo set HealthPlanUserNote = @Note, LastUpdate = getutcdate(),
			HealthPlanNoteLastUpdate = getutcdate()
		where MVDID = @MVDId
	end
	else
	begin
		insert into UserAdditionalInfo (MVDID,IsPackageSent, HealthPlanUserNote, HealthPlanNoteLastUpdate) 
			VALUES (@MVDId, '0', @Note, getutcdate())
	end
end