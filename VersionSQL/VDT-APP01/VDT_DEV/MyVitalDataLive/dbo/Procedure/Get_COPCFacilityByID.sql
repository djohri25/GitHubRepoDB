/****** Object:  Procedure [dbo].[Get_COPCFacilityByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================
CREATE PROCEDURE [dbo].[Get_COPCFacilityByID]
	@ID varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	declare @NPIList varchar(max)
	
	set @NPIList = ''
	
	select @NPIList = @NPIList + ma.NPI + ':' + dbo.FullName(n.[Provider Last Name (Legal Name)],n.[Provider First Name],'') + ';'
	from Link_CopcFacilityNPI ma
		inner join dbo.LookupNPI n on ma.NPI = n.NPI
	where CopcFacilityID = @ID
	
	if(ISNULL(@NPIList,'') <> '')
	begin
		set @NPIList = SUBSTRING(@NPIList, 0, len(@NPIList))
	end
	
	SELECT ID
      ,FacilityName
      ,Active
      ,CreationDate
      ,ModifyDate
      ,@NPIList as 'NPIList'
  FROM CopcFacility
  where ID = @ID
END