/****** Object:  Procedure [dbo].[Get_NDCList]    Committed by VersionSQL https://www.versionsql.com ******/

Create Proc [dbo].[Get_NDCList]
(@NDCCode varchar(30))
AS
BEGIN

--Declare @NDCCode	varchar(100)
--Set @NDCCode = '36987160302'

Declare @RXCUI table (RXCUI varchar(8))

INSERT INTO @RXCUI
Select Distinct RXCUI from Lookup_RXNorm Where NDCCode = @NDCCode

SELECT NDCCode FROM Lookup_RXNorm where RXCUI in (Select RXCUI from @RXCUI)

END