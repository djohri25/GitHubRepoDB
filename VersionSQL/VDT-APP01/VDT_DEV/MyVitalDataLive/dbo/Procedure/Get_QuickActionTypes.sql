/****** Object:  Procedure [dbo].[Get_QuickActionTypes]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 10/24/2018
-- Description:	Get all QuickAction Types 
-- =============================================
CREATE PROCEDURE [dbo].[Get_QuickActionTypes]
--	@UserName - later add this to enable user administration capability to retrieve any quick action type
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select 
		Id
		,TypeName
		,TypeDescription
		,CreatedDate
		,CreatedBy
		,UpdatedDate
		,UpdatedBy
		,IsActive
	from QuickActionType
	where IsActive = 1
END