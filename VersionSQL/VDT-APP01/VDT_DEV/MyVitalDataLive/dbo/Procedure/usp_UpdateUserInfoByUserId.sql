/****** Object:  Procedure [dbo].[usp_UpdateUserInfoByUserId]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE proc [dbo].[usp_UpdateUserInfoByUserId] 
@UserId varchar(128),
@Supervisor varchar(128),
@Department varchar(128),
@Signature varchar(128),
@AgentId varchar(128),
@Groups varchar(128)

as


Set NOCOUNT ON

Update
[AspNetIdentity].[dbo].[AspNetUserInfo]

SET 
Supervisor =@Supervisor
,Department= @Department
,Signature= @Signature
,AgentId= @AgentId
WHERE 
UserId =@UserId