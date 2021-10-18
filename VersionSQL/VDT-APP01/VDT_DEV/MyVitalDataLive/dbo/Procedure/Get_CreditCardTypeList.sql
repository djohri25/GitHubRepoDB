/****** Object:  Procedure [dbo].[Get_CreditCardTypeList]    Committed by VersionSQL https://www.versionsql.com ******/

create PROCEDURE [dbo].[Get_CreditCardTypeList]
AS
BEGIN
	SET NOCOUNT ON

	SELECT	ID, Name 
	FROM	LookupCreditCardType
END