/****** Object:  Procedure [dbo].[Get_TaskAlertDictionary]    Committed by VersionSQL https://www.versionsql.com ******/

--***************
----[Get_TaskAlertDictionary]
--***************

-- =============================================
-- Author:		Spaitereddy
-- Create date: 03/15/2019
-- Description:	Get user's tasks.
-- =============================================


CREATE procedure [dbo].[Get_TaskAlertDictionary] 
@ProductID int,
@CustID int ,
@codetypeid int = null


AS 
BEGIN 

if @codetypeid is null 
set @codetypeid = 18

SET NOCOUNT ON;

select codeid, label from [dbo].[Lookup_Generic_Code]
where codetypeid = @codetypeid and cust_id=@CustID and ProductID=@ProductID

END 