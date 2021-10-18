/****** Object:  Procedure [dbo].[GET_AssignedUser]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		MIKE G
-- Create date: 07/17/19
-- Description:	Save Member Ownership Data
-- =============================================
CREATE PROCEDURE [dbo].[GET_AssignedUser]	
	@MVDID varchar(30) null,
	@CustID int null

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT ID, CustID, MVDID,OwnerType, OwnerName, FirstName, LastName, StartDate, EndDate, CreatedBy, IsDeactivated, AssignmentTypeCodeID FROM Final_MemberOwner where MVDID=@MVDID and CustID = @CustID;
	
--	select ID,CustID, MVDID,OwnerType, t.OwnerName, FirstName, LastName, StartDate, EndDate, CreatedBy, t.IsDeactivated FROM Final_MemberOwner t
--inner join (
--select OwnerName, IsDeactivated, max(startdate) as MaxDate
--from Final_MemberOwner
--where MVDID=@MVDID and CustID = @CustID
--group by ownername,IsDeactivated
--) tm on t.ownername = tm.ownername and t.startdate = tm.MaxDate
--where MVDID =@MVDID  
--order by MVDID

	--SELECT top 1 ID, CustID, MVDID,OwnerType, OwnerName, FirstName, LastName, StartDate, EndDate, CreatedBy, IsDeactivated FROM Final_MemberOwner where MVDID='1660F7EE340EAA96316B' and CustID = 16 group by ID, CustID, MVDID,OwnerType, OwnerName, FirstName, LastName, StartDate, EndDate, CreatedBy, IsDeactivated order by StartDate desc
	--SELECT DISTINCT CustID, MVDID,OwnerType, OwnerName, FirstName, LastName, StartDate, EndDate, CreatedBy, IsDeactivated FROM Final_MemberOwner where MVDID='1660F7EE340EAA96316B' and CustID = 16 group by CustID, MVDID,OwnerType, OwnerName, FirstName, LastName, StartDate, EndDate, CreatedBy, IsDeactivated having (StartDate) = MAX(StartDate) 
		
END