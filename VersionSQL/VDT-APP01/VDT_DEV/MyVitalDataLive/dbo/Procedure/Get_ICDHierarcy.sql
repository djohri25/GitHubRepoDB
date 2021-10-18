/****** Object:  Procedure [dbo].[Get_ICDHierarcy]    Committed by VersionSQL https://www.versionsql.com ******/

Create Procedure [dbo].[Get_ICDHierarcy] 
(
	@Code	varchar(10)
)
AS 
BEGIN 
--Declare @COde Varchar(10)
--Select @Code = 'Y37'

;WITH Hierarchy(Code, CodeNoPeriod, ICDNo, ParentCode, ParentCodeNoPeriod, Generation)
AS
(
    SELECT distinct Code,CodeNoPeriod, ICDNo, ParentCode, ParentCodeNoPeriod, 0 as Generation
        FROM LookupICD9 AS FirtGeneration
        WHERE (Code = @Code or CodeNoPeriod = @Code)--'C40'
    UNION ALL
    SELECT NextGeneration.Code, NextGeneration.CodeNoPeriod, NextGeneration.ICDNo, NextGeneration.ParentCode,NextGeneration.ParentCodeNoPeriod , Parent.Generation + 1
		FROM LookupICD9 AS NextGeneration
        INNER JOIN Hierarchy AS Parent ON NextGeneration.ParentCode = Parent.Code   
)
SELECT  Generation,  ParentCode, ParentCodeNoPeriod,Code as ChildCode, CodeNoPeriod as ChildCodeNoPeriod, ICDNo
    FROM Hierarchy
    OPTION(MAXRECURSION 32767)

END