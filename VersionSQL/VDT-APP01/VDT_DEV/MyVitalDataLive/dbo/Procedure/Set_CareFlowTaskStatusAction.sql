/****** Object:  Procedure [dbo].[Set_CareFlowTaskStatusAction]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 10/25/2018
-- Description:	Update CareFlowTask action and status
-- =============================================
CREATE PROCEDURE [dbo].[Set_CareFlowTaskStatusAction]
	@Id int,
	@StatusId int,
	@ActionId smallint,
	@UpdatedDate datetime,
	@UpdatedBy varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    update CareFlowTask
	set 
		StatusId = @StatusId,
		ActionId = @ActionId,
		UpdatedDate = @UpdatedDate,
		UpdatedBy = @UpdatedBy
	where Id = @Id
END