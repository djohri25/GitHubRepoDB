/****** Object:  Procedure [dbo].[Get_COPC_MemberConditionLookup]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9/5/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_COPC_MemberConditionLookup]
AS
BEGIN
	SET NOCOUNT ON;

    select ID, Name, Abbreviation 
    from LookupDRMyPatientsDisease 
    where Abbreviation in ('AST','W15')
    order by OrderInd 
END