/****** Object:  Procedure [dbo].[SET_AssignedUser_090919]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		MIKE G
-- Create date: 07/17/19
-- Description:	Save Member Ownership Data
-- =============================================
CREATE PROCEDURE [dbo].[SET_AssignedUser]
	@AssignedBy varchar(100) null,
	@MVDID varchar(30) null,
	@OwnerType varchar(50) null,
	@FirstName varchar(100) null,
	@LastName varchar(100) null,
	@User varchar(100) NULL,
	@GroupID  smallint null,
	@UserID nvarchar(128) null,
	@StartDate varchar(100) NULL,
	@EndDate varchar(100) NULL,	
	@CustID int null,
	--@IsPrimary bit,
	@IsDeactivated bit

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	Declare @isprimaryAvailable varchar (100) 	
		Select top 1 @isprimaryAvailable = OwnerType  from Final_MemberOwner where CustID= @CustID and MVDID= @MVDID and OwnerType=@OwnerType		
		if (@isprimaryAvailable ='Primary')
			BEGIN
				--select @isprimaryAvailable
				UPDATE [dbo].[Final_MemberOwner] SET OwnerType='' where CustID= @CustID and MVDID= @MVDID 
					INSERT INTO [dbo].Final_MemberOwner
						(CreatedBy, UserID, GroupID, OwnerName, FirstName, LastName, StartDate, EndDate, CustID, MVDID, OwnerType, IsDeactivated)
						VALUES(@AssignedBy, @UserID, @GroupID, @User, @FirstName, @LastName, @StartDate, @EndDate, @CustID, @MVDID, @OwnerType, @IsDeactivated );
			END	
		else
				
			BEGIN
			
				INSERT INTO [dbo].[Final_MemberOwner]
				(CreatedBy, UserID, GroupID, OwnerName, FirstName, LastName, StartDate, EndDate, CustID, MVDID, OwnerType, IsDeactivated)
						VALUES(@AssignedBy, @UserID, @GroupID, @User, @FirstName, @LastName, @StartDate, @EndDate, @CustID, @MVDID, @OwnerType, @IsDeactivated );
			END

END