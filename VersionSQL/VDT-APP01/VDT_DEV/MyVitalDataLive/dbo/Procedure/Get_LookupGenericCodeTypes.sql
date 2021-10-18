/****** Object:  Procedure [dbo].[Get_LookupGenericCodeTypes]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 03/13/2017
-- Description:	Returns all LookupGenericCodeTypes
-- =============================================
CREATE PROCEDURE [dbo].[Get_LookupGenericCodeTypes]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select CodeTypeID, CodeType
	from Lookup_Generic_Code_Type
    
END