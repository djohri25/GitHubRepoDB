/****** Object:  Procedure [dbo].[Upd_CCC_StakeholderUsers]    Committed by VersionSQL https://www.versionsql.com ******/

Create Procedure [dbo].[Upd_CCC_StakeholderUsers]

(	@CustID int, 
	@UserName	varchar(100), 
	@SHGroupID int , 
	@ManagerUserName	varchar(100) = NULL
)
AS 
BEGIN
--Declare @CustID int, @UserName	varchar(100), @SHGroupID int , @ManagerUserName	varchar(100) = NULL
--SELECT @UserName = 'scain', @SHGroupID = 2, @CustID = 15

Declare @UserID varchar(200), @ManagerUserID varchar(200)

	IF Exists (Select 1 from Link_CCC_UserSHGroup Where UserName = @UserName)
	BEGIN
		IF  @SHGroupID is NULL
		BEGIN
			UPDATE Link_CCC_UserSHGroup
			SET SHGroupID = @SHGroupID, Updated = GETUTCDATE()
			Where UserName = @UserName
		END
		ELSE IF (Select top 1 ID from CCC_StakeholderGroup where ID = @SHGroupID) is not null
		BEGIN
			UPDATE Link_CCC_UserSHGroup
			SET SHGroupID = @SHGroupID, Updated = GETUTCDATE()
			Where UserName = @UserName
		END
		ELSE
		BEGIN
			Raiserror ('Update failed. Invalid Stakeholder groupID is passed', 16, 1)
		END
	END
	ELSE IF NOT EXISTS (Select 1 from Link_CCC_UserSHGroup Where UserName = @UserName)
	BEGIN
	
		Select @UserID = U.UserID
		From MVDSupportLive.dbo.aspnet_Membership M JOIN MVDSupportLive.dbo.aspnet_Users U ON U.UserID = M.UserID 
		Where M.CustomerId = @CustID and U.UserName = @UserName

		Select @ManagerUserID = U.UserID
		From MVDSupportLive.dbo.aspnet_Membership M JOIN MVDSupportLive.dbo.aspnet_Users U ON U.UserID = M.UserID 
		Where M.CustomerId = @CustID and U.UserName = @ManagerUserName


		INSERT INTO Link_CCC_UserSHGroup (Userid,UserName,SHGroupID,ManagerID,ManagerName)
		Select @UserID, @UserName, @SHGroupID, @ManagerUserID, @ManagerUserName

	END

END