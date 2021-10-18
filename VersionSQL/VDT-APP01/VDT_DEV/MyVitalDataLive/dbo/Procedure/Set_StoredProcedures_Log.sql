/****** Object:  Procedure [dbo].[Set_StoredProcedures_Log]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Modify date: 8/5/2014
-- Description:	Record SP Log
-- =============================================
CREATE PROCEDURE [dbo].[Set_StoredProcedures_Log]
	@SPName nvarchar(100),
	@UserID nvarchar(50) = null,
	@UserID_SSO nvarchar(50) = null,
	@Parameters nvarchar(1000) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO [dbo].[StoredProcedures_Log]
           ([SPName]
           ,[UserID]
           ,[UserID_SSO]
           ,[Parameters])
     VALUES
           (@SPName
           ,@UserID
           ,@UserID_SSO
           ,@Parameters)
END