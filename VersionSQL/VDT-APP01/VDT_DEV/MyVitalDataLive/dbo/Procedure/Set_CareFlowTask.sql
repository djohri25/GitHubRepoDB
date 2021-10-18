/****** Object:  Procedure [dbo].[Set_CareFlowTask]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 10/24/2018
-- Description:	Add or updated CareFlowTask.
-- =============================================
CREATE PROCEDURE [dbo].[Set_CareFlowTask]
	@Id	int = NULL,
	@UniqueRecordCheckSum	varchar(250) = NULL,
	@MVDID	varchar(10),
	@RuleId	smallint,
	@ExpirationDate	datetime,
	@ActionId	smallint = NULL,
	@CreatedDate	datetime,
	@CreatedBy	varchar(20) = NULL,
	@UpdatedDate	datetime,
	@UpdatedBy	varchar(20) = NULL,
	@ParentTaskId	int = NULL,
	@IsSoftDeleted	bit = NULL,
	@ProductId	int,
	@CustomerId	int,
	@TaskOwner	smallint,
	@StatusId	int,
	@NewID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if(@Id is not null)
		Begin
			Insert into CareFlowTask
			values
			(
				@UniqueRecordCheckSum
				,@MVDID
				,@RuleId
				,@ExpirationDate
				,@ActionId
				,@CreatedDate
				,@CreatedBy
				,@UpdatedDate
				,@UpdatedBy
				,@ParentTaskId
				,@IsSoftDeleted
				,@ProductId
				,@CustomerId
				,@TaskOwner
				,@StatusId
			)

			set @NewID = Scope_Identity()
		end
	else
		Begin
			update CareFlowTask
			set
				UniqueRecordCheckSum=	@UniqueRecordCheckSum
				,MVDID=	@MVDID
				,RuleId=	@RuleId
				,ExpirationDate=	@ExpirationDate
				,ActionId=	@ActionId
				,CreatedDate=	@CreatedDate
				,CreatedBy=	@CreatedBy
				,UpdatedDate=	@UpdatedDate
				,UpdatedBy=	@UpdatedBy
				,ParentTaskId=	@ParentTaskId
				,IsSoftDeleted=	@IsSoftDeleted
				,ProductId=	@ProductId
				,CustomerId=	@CustomerId
				,TaskOwner=	@TaskOwner
				,StatusId=	@StatusId
			where Id = @Id
		end
END