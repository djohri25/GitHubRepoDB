/****** Object:  Procedure [dbo].[Get_HpCustomerInfoForLoggedInUser]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 02/11/2016
-- Description:	This SP will return HPCustomer's name and ID for a logged-in MDUser.
-- =============================================
CREATE PROCEDURE [dbo].[Get_HpCustomerInfoForLoggedInUser]
	@UserName varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select hpc.Cust_ID as CustID
		  ,hpc.Name as HPName
	from MDUser as mdu
	join Link_MDAccountGroup as lmdag on mdu.ID = lmdag.MDAccountID
	join MDGroup as mdg on lmdag.MDGroupID = mdg.ID
	join HPCustomer as hpc on mdg.CustID_Import = hpc.Cust_ID
	where mdu.Username = @UserName
END