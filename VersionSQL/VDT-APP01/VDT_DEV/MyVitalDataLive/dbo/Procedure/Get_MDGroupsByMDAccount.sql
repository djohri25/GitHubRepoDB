/****** Object:  Procedure [dbo].[Get_MDGroupsByMDAccount]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_MDGroupsByMDAccount]
	@AccountId varchar(50) = null,
	@drUsername varchar(50) = null,
	@Cust_ID int = null,
	@ShowAll bit
AS
BEGIN
	SET NOCOUNT ON;
 
  	-- Holds temporary result
	declare @tempTab table (id varchar(50), GroupName varchar(100), isSelected bit default(0))

	if(@AccountId is null and @drUsername is not null)
	begin
		select @AccountId = ID
		from MDUser
		where Username = @drUsername
	end

	if(@ShowAll = 1)
	begin
		if isnull(@Cust_ID, 0) = 0
		begin
			insert into @tempTab (id,GroupName)
			SELECT ID,GroupName FROM MDGroup
		END
		else
		begin
			insert into @tempTab (id,GroupName)
			SELECT ID, GroupName
			FROM MDGroup
			where CustID_Import = @Cust_ID
		end

		-- Set Select flag only if @RuleId is valued
		if(isnull(@AccountId,'') <> '' and @AccountId <> '0')
		begin
			update @tempTab set isSelected = 1 where id in( 
				select MDGroupID from dbo.Link_MDAccountGroup
				 where MDAccountId = @AccountId)
		end

		select id, GroupName, isSelected 
		from @tempTab
		order by GroupName
	end
	else 
	begin
		-- Selected only rows previously selected by the user

		SELECT ID, GroupName,1 as isSelected 
		from MDGroup a
			inner join Link_MDAccountGroup b on a.ID = b.MDGroupID 
		where MDAccountId = @AccountId		
		order by GroupName
	end

END