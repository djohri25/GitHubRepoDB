/****** Object:  Function [dbo].[Get_ICDCodesList]    Committed by VersionSQL https://www.versionsql.com ******/

 CREATE Function [dbo].[Get_ICDCodesList]
 (	@Code	VARCHAR(10))
 RETURNS	@result  TABLE (Code varchar(50))
 AS 
 BEGIN
 	INSERT INTO @result
	Select Distinct Code
	From  LookupICD9  
	Where (Code like '%'+@Code+'%' or CodeNoPeriod like '%'+@Code+'%')

 return
 END