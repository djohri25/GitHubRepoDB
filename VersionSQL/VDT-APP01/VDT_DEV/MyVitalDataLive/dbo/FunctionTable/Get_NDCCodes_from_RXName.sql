/****** Object:  Function [dbo].[Get_NDCCodes_from_RXName]    Committed by VersionSQL https://www.versionsql.com ******/

  CREATE Function [dbo].[Get_NDCCodes_from_RXName]
 (
	@RxName varchar(150)
 )
 RETURNS @result TABLE (NDCCode varchar(50))
  AS
 BEGIN
	INSERT INTO @result
	Select Distinct Code as NDCCode 
	From MainMedication 
	Where RxDrug like '%'+@RxName+'%'

 return
 END