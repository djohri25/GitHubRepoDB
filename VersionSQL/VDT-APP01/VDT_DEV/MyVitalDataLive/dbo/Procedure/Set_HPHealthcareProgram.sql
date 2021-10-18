/****** Object:  Procedure [dbo].[Set_HPHealthcareProgram]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_HPHealthcareProgram]
	@CustomerID varchar(15),
	@ProgramName varchar(100),
	@ProgramDescription varchar(300),
	@ProgramPhone varchar(50),
	@Result int out
AS
BEGIN
	SET NOCOUNT ON;

	declare @parentCustID int

	set @parentCustID = dbo.Get_HPParentCustomerID(@customerID)

	set @result = -1

	if exists (select id from dbo.HPHealthcareProgram where cust_id = @parentCustID AND name = @ProgramName)
	begin
		set @result = -2
	end
	else
	begin
		insert into HPHealthcareProgram (Cust_ID,Name,Description,Phone,Extension)
		values (@parentCustID,@Programname,@programdescription,@programPhone,'')
		
		set @result = 0
	end	
END