/****** Object:  Procedure [dbo].[LockMergedMMF]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[LockMergedMMF] 
	-- Add the parameters for the stored procedure here
	@FormID bigint
AS
BEGIN

	UPDATE [dbo].[ABCBS_MemberManagement_Form] 
	SET IsLocked = 'LockedWithCaseClose', SectionCompleted = 5
	WHERE ID = @FormID
		
END;