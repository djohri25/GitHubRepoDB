/****** Object:  Procedure [dbo].[Get_RoleList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_RoleList]
@Language BIT = 1
As

Set Nocount On
IF(@Language = 1)
	BEGIN -- 1 = english
		Select RoleID, RoleName From  LookupRoleID Order By RoleId
	END
ELSE
	BEGIN -- 0 = spanish
		Select RoleID, RoleNameSpanish RoleName From  LookupRoleID Order By RoleId
	END