/****** Object:  Procedure [dbo].[Get_HCC_Hierarchies]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Proc [dbo].[Get_HCC_Hierarchies]
@Year int = NULL
AS
BEGIN
IF (@Year = 2014 or @Year is NULL)
BEGIN
	SELECT  [Obs]
		  ,[HCC]
		  ,[Set_to_0_HCCs]
		  ,[HCCLabel]
	  FROM [dbo].[HCC_Hierarchies_2014]
END

END