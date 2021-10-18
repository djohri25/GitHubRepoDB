/****** Object:  Procedure [dbo].[Get_LOB_By_Cust_ID]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROC [dbo].[Get_LOB_By_Cust_ID]
(@Cust_ID	INT)
AS 
BEGIN

Select Distinct G.CodeId, G.Label, G.Label_Desc  FROM Lookup_Generic_Code  G JOIN Lookup_Generic_Code_Type GT ON GT.CodeTypeID = G.CodeTypeID 
	WHERE Cust_ID = @Cust_ID and GT.CodeType = 'LOB'

END