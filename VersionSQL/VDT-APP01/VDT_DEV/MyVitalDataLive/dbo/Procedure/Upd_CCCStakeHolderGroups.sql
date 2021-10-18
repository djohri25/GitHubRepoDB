/****** Object:  Procedure [dbo].[Upd_CCCStakeHolderGroups]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dbo].[Upd_CCCStakeHolderGroups]
(
	@SHGroupID int = NULL , 
	@StakeholderGroup	varchar(200), 
	@UserType varchar(100), @Output int out
)
AS 
BEGIN
	set @Output = -1 
	IF @SHGroupID is not NULL 
	BEGIN
		
		update  dbo.CCC_StakeholderGroup
		set StakeholderGroup = @StakeholderGroup, UserType = @UserType , Updated = GETUTCDATE()
		where ID = @SHGroupID

		Set @Output = 0
	END
	else IF @SHGroupID is NULL
	BEGIN
		IF not exists (Select 1 from dbo.CCC_StakeholderGroup where StakeholderGroup = @StakeholderGroup)
		BEGIN
			INSERT INTO dbo.CCC_StakeholderGroup (StakeholderGroup, UserType, Created)
			Select @StakeholderGroup, @UserType, GETUTCDATE()

			Set @Output = SCOPE_IDENTITY();
		END
	END
	
	Return;
	
END