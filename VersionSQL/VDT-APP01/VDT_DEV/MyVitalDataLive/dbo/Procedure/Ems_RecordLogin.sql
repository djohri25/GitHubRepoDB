/****** Object:  Procedure [dbo].[Ems_RecordLogin]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Records the EMS login to the system
*/
CREATE Procedure [dbo].[Ems_RecordLogin]
	@Email varchar(50),
	@EmployeeID varchar(50),
	@IpAddress varchar(15),
	@Result int OUT
AS

	SET NOCOUNT ON

	insert into EMS_LoginRecord(EMS_ID, EmployeeID, LoginIP)
	values(@Email, @EmployeeID, @IpAddress)
	
	set @Result = 1
		