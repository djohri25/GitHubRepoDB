/****** Object:  Procedure [dbo].[uspInsertUserInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dbo].[uspInsertUserInfo]

@UserId nvarchar(128),
@Department nvarchar(128),
@Supervisor nvarchar(128),
@Groups     nvarchar(max)
AS

DECLARE @Id uniqueidentifier = newId();
INSERT INTO [dbo].[AspNetUserInfo]
           (Id
		    ,[UserId]
           ,[Department]
           ,[Supervisor]
		   ,[Groups])
     VALUES
           (
			 @Id
		    ,@UserId
            ,@Department
		    ,@Supervisor
			,@Groups)

SELECT * FROM AspNetUserInfo
WHERE Id= @Id