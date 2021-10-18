/****** Object:  Procedure [dbo].[Remove_CareSpaceNotes_Demo]    Committed by VersionSQL https://www.versionsql.com ******/

Create Proc dbo.Remove_CareSpaceNotes_Demo
(@MVDID	varchar(30))
AS
BEGIN

declare @TableName varchar(100), @ID int, @SQL varchar(1000)--, @MVDID varchar(30)

--SET @MVDID = 'SB275575'

Delete from HPAlertNote Where MVDID = @MVDID and NoteTypeID in (7,8,9) and LinkedFormID is  null

IF OBJECT_ID ('TempDB.dbo.#CarePlan','U') is not null 
drop table #CarePlan
Create Table #CarePlan (CarePlanID	int)

IF OBJECT_ID ('TempDB.dbo.#Temp','U') is not null 
drop table #Temp
select distinct LinkedFormType+'_Form' as TableName, LinkedFormID as ID 
INTO #Temp
from HPAlertNote Where MVDID = @MVDID and ISNULL(NoteTypeID,10) in (10) and LinkedFormID is  not null

select * from #Temp
While EXISTS (Select 1 from #Temp)
BEGIN
	Select top 1 @TableName = TableName, @ID = ID from #Temp

	IF @TableName <> 'CCC_CarePlan_Form'
	BEGIN
		SET @SQL = N'Delete FROM '+''+@TableName+' Where ID = '+ ''+CAST(@ID as varchar(10))+''
		exec (@SQL)
	END
	ELSE IF @TableName = 'CCC_CarePlan_Form'
	BEGIN
		INSERT INTO #CarePlan (CarePlanID)
		SELECT CarePlanID 
		FROM [dbo].[MainCarePlanIndex] where MVDID = @MVDID

		Delete from  [dbo].[MainCarePlanGoals] Where CarePlanID in (Select * from #CarePlan)
		Delete from  [dbo].[MainCarePlanProblems] Where CarePlanID in (Select * from #CarePlan)
		Delete from  [dbo].[MainCarePlanIndex] Where CarePlanID in (Select * from #CarePlan)
	END

	Delete FROm HPAlertNote Where MVDID = @MVDID and ISNULL(NoteTypeID,10) in (10) and LinkedFormID = @ID and LinkedFormType+'_Form' = @TableName

	Delete from #Temp where TableName = @TableName and ID = @ID
END
Delete from HPAlertNote Where MVDID = @MVDID 

END