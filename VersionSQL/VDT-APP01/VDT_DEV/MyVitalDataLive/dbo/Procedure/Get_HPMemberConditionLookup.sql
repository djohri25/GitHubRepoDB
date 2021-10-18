/****** Object:  Procedure [dbo].[Get_HPMemberConditionLookup]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/21/2011
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Get_HPMemberConditionLookup]
	@CustID varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	select ID,Name 
	from dbo.LookupMemberConditionSummary
END