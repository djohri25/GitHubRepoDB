/****** Object:  Procedure [dbo].[Get_GenericCodeType]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_GenericCodeType] 
	@CustID int,
	@ProductID int
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
select GC.Label, GCT.CodeType from Lookup_Generic_Code GC join
Lookup_Generic_Code_Type GCT ON GC.CodeTypeID = GCT.CodeTypeID where GC.CodeID = 287 and GC.Cust_ID = @CustID and GC.ProductID = @ProductID


END