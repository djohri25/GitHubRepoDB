/****** Object:  Procedure [dbo].[Get_LBCheckValue]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	used by load balancer check website
-- =============================================
CREATE PROCEDURE [dbo].[Get_LBCheckValue]
AS
BEGIN
	SET NOCOUNT ON;

	select top 1 Name from hpcustomer
END