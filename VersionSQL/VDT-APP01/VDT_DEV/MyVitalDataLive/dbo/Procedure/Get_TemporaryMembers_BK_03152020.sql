/****** Object:  Procedure [dbo].[Get_TemporaryMembers_BK_03152020]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create Procedure [dbo].[Get_TemporaryMembers_BK_03152020] 
	-- Add the parameters for the stored procedure here
	@CustID int
AS
BEGIN

select MVDID as IceNumber, MemberID as InsMemberId, MemberFirstName as FirstName, MemberLastName as LastName, SSN, DateOfBirth as DOB 
from FinalMemberTemporary where CustID = @CustID

END