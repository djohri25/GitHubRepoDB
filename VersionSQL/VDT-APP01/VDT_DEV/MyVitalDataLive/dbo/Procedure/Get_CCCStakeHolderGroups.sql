/****** Object:  Procedure [dbo].[Get_CCCStakeHolderGroups]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dbo].[Get_CCCStakeHolderGroups] (@SHGroupID INT = NULL)
AS
BEGIN
	Select ID as SHGroupID, StakeholderGroup, UserType, Created, Updated from CCC_StakeholderGroup where (ID = @SHGroupID or @SHGroupID is null)
END