/****** Object:  Procedure [dbo].[Set_MemberAccess_Log]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Modify date: 8/5/2014
-- Description:	Record SP Log
-- =============================================
CREATE PROCEDURE [dbo].[Set_MemberAccess_Log]
	@UserID nvarchar(50) = null,
	@PatientID nvarchar(50) = null,
	@PageName nvarchar(150) = null,
	@Cust_ID nvarchar(50) = null,
	@Result nvarchar(150) = null
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO [dbo].[MemberAccess_Log]
           ([UserID]
      ,[LoggingDate]
      ,[PatientID]
	  ,[PageName]
	  ,[Cust_ID]
	  ,[Result])
     VALUES
           (@UserID
		    ,GETDATE() 
           ,@PatientID
		   ,@PageName
		   ,@Cust_ID
		   ,@Result)
END