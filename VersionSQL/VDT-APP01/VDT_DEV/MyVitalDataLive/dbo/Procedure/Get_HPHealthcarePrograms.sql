/****** Object:  Procedure [dbo].[Get_HPHealthcarePrograms]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 6/21/2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPHealthcarePrograms]
	@CustomerID int
AS
BEGIN
	SET NOCOUNT ON;

	declare @hpParentCustId int

	set @hpParentCustID = dbo.Get_HPParentCustomerID(@CustomerID)	

	select ID, Name, Description, dbo.FormatPhone(Phone) as phone, Extension
	from dbo.HPHealthcareProgram 
	where Cust_ID = @hpParentCustID
END