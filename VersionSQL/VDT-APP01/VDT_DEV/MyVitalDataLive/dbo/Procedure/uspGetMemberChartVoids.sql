/****** Object:  Procedure [dbo].[uspGetMemberChartVoids]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 08/31/2020
-- Description:	Get chart void records for MVDID
-- =============================================
CREATE PROCEDURE [dbo].[uspGetMemberChartVoids]
	@MVDID varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [Id]
      ,[MVDID]
      ,[ChartEntityTypeId]
      ,[ChartEntityId]
      ,[RequestedBy]
      ,[VoidReasonId]
      ,[CreatedBy]
      ,[CreatedDate]
	FROM [dbo].[ChartVoid]
	where MVDID = @MVDID
    
END