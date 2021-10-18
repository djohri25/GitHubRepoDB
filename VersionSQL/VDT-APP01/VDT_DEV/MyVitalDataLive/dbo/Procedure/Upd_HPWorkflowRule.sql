/****** Object:  Procedure [dbo].[Upd_HPWorkflowRule]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/01/2008
-- Description:	 Updates an instance of AlertingRule
-- =============================================
CREATE PROCEDURE [dbo].[Upd_HPWorkflowRule]
	@ID int,
	@Group varchar(50),
	@Name varchar(50),
	@Description varchar(500),
	@CustomerId int,
	@Body varchar(max) = null,
	@Active bit,
	@Action_ID int,
	@Action_Days int,
	@Query varchar(max) = null,
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;
	set @Result = -1

	if not exists(select Name from HPWorkflowRule where Name = @Name and Cust_Id = @CustomerId and Rule_ID <> @ID)
	begin
		-- update record in main rule table
		update dbo.HPWorkflowRule set
			Cust_Id = @CustomerId,
			[Group] = @Group,
			[Name] = @Name,
			[Description] = @Description,
			Active = @Active,
			Action_ID = @Action_ID,
			Action_Days = @Action_Days,
			Body = @Body,
			Query = @Query
		where Rule_ID = @Id
		set @Result = 0
	end
END