/****** Object:  Procedure [dbo].[Get_TaskAlert]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE procedure [dbo].[Get_TaskAlert] 
@MVDID varchar(20),
@ProductID int =NULL,
@CustID int 
--,@codetype int = null 

AS 
BEGIN 

SET NOCOUNT ON;


IF @ProductID IS NULL 
SET @ProductID =2

--IF @codetype is null 
--set @codetype =5


SELECT [ID]
      ,[MVDID]
      ,[CustID]
      ,[CodeID]
      ,[CodeTypeID]
      ,[Label]
      ,[LabelDesc]
  FROM [dbo].[TaskAlert]
  where [MVDID]=@MVDID and [CustID]=@CustID
  -- and T.CodeTypeID=@codetype

END