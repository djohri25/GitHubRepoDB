/****** Object:  Procedure [dbo].[Set_TaskAlert]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Spaieterddy
-- Create date: 03/15/2019
-- Description:	Insert/Update user created task.
-- =============================================



CREATE procedure [dbo].[Set_TaskAlert] 
@MVDID varchar(20),
@ProductID int =NULL,
@CustID int ,
@ID int = null,
@CodeID int = null,
@User varchar(100)
--,@codetype int

AS 
BEGIN 

SET NOCOUNT ON;

declare @UTCDateTime datetime
SET @UTCDateTime= GETUTCDATE()

IF @ProductID IS NULL 
SET @ProductID =2


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