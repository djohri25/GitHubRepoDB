/****** Object:  Procedure [dbo].[Set_MemberAlert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Spaieterddy
-- Create date: 03/21/2019
-- MODIFIED: Spaitereddy, 03/26/2019, generated values from coma separated list
-- Description:	Insert/Update user created task.
-- =============================================



CREATE procedure [dbo].[Set_MemberAlert] 
@MVDID varchar(20),
@ProductID int =NULL,
@CustID int ,
@ID int = null,
@IDList varchar(200)=null,
@CodeID int = null,
@User varchar(100),
@flg int = null
--,@codetype int

AS 
BEGIN 

SET NOCOUNT ON;

declare @UTCDateTime datetime
SET @UTCDateTime= GETUTCDATE()

IF @ProductID IS NULL 
SET @ProductID =2

--declare @IDList varchar(200)
--set @idlist = '1'




if (@CodeID is not null)

begin 

--select @CodeID= CodeID from #TempList

IF NOT EXISTS (SELECT 1 FROM TaskAlert WHERE CodeID =@CodeID AND MVDID = @MVDID)
BEGIN 

INSERT INTO TaskAlert (
	   [MVDID]
      ,[CustID]
      ,[CodeID]
      ,[CodeTypeID]
      ,[Label]
      ,[LabelDesc]
      ,[ProductID]
      ,[CreatedDT]
      ,[CreatedBy])
SELECT 
       @MVDID
      ,@CustID
      ,C.[CodeID]
      ,C.[CodeTypeID]
      ,c.[Label]
      ,C.Label_Desc
      ,@ProductID
      ,@UTCDateTime
      ,@User
FROM [dbo].Lookup_Generic_Code C
INNER JOIN Lookup_Generic_Code_Type T
ON C.CodeTypeID=T.CodeTypeID
WHERE c.CodeID=@CodeID
-- and T.CodeTypeID=@codetype

END 

else 

IF EXISTS (SELECT 1 FROM TaskAlert WHERE CodeID =@CodeID AND MVDID = @MVDID)
BEGIN 

DELETE FROM TaskAlert
WHERE 
CodeID =@CodeID AND MVDID = @MVDID

DBCC CHECKIDENT ('TaskAlert', RESEED, 1)

END

END

if (@IDList is not null)

Begin 

drop table if exists #TempList

	CREATE TABLE #TempList
	(
		CodeID int
	)

DECLARE @newCodeID varchar(10), @Pos int

	SET @IDList = LTRIM(RTRIM(@IDList))+ ','
	SET @Pos = CHARINDEX(',', @IDList, 1)

	IF REPLACE(@IDList, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @newCodeID = LTRIM(RTRIM(LEFT(@IDList, @Pos - 1)))
			IF @newCodeID <> ''
			BEGIN
				INSERT INTO #TempList (CodeID) VALUES (CAST(@newCodeID AS int)) --Use Appropriate conversion
			END
			SET @IDList = RIGHT(@IDList, LEN(@IDList) - @Pos)
			SET @Pos = CHARINDEX(',', @IDList, 1)

		END
	END	



declare @count int 
select @count= count(*) from #TempList


if (@count>1 and @flg=1)
BEGIN 

--IF NOT EXISTS (SELECT 1 FROM TaskAlert WHERE CodeID in (select CodeID from  #TempList ) and [MVDID]= @MVDID)

--Begin 

INSERT INTO TaskAlert (
	   [MVDID]
      ,[CustID]
      ,[CodeID]
      ,[CodeTypeID]
      ,[Label]
      ,[LabelDesc]
      ,[ProductID]
      ,[CreatedDT]
      ,[CreatedBy])
SELECT distinct 
       @MVDID
      ,@CustID
      ,M.[CodeID]
      ,M.[CodeTypeID]
      ,M.[Label]
      ,M.Label_Desc
      ,@ProductID
      ,@UTCDateTime
      ,@User
	  from 
(select L.[CodeID]
      ,C.[CodeTypeID]
      ,c.[Label]
      ,C.Label_Desc FROM [dbo].Lookup_Generic_Code C
INNER JOIN Lookup_Generic_Code_Type T
ON C.CodeTypeID=T.CodeTypeID
inner join #TempList L
on L.CodeID=c.codeid) M
left join TaskAlert task
on task.CodeID=M.CodeID
and  task.MVDID=@MVDID and task.custid=@CustID
where task.CodeID is null


END 

--else 

IF (@flg=2)

--EXISTS (SELECT 1 FROM TaskAlert WHERE CodeID in (select CodeID from  #TempList ) and [MVDID]= @MVDID)
BEGIN 

DELETE FROM TaskAlert
WHERE 
CodeID in (select CodeID from  #TempList) and MVDID = @MVDID

--(select CodeID from  #TempList l left join TaskAlert task
--on task.CodeID=L.CodeID
--AND task.MVDID=@MVDID and task.custid=@CustID
--and task.CodeID is null
-- ) AND MVDID = @MVDID

DBCC CHECKIDENT ('TaskAlert', RESEED, 1)

END
End


END