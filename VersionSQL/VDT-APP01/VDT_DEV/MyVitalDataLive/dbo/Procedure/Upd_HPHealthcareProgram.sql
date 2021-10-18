/****** Object:  Procedure [dbo].[Upd_HPHealthcareProgram]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Upd_HPHealthcareProgram]
	@ProgramID int,
	@CustomerID varchar(15),		-- Assumption: program cannot change the customer
	@ProgramName varchar(100),
	@ProgramDescription varchar(300),
	@ProgramPhone varchar(50),
	@Result int out
AS
BEGIN
	SET NOCOUNT ON;

	set @result = -1

	if exists (select id from dbo.HPHealthcareProgram where id <> @programID and Name = @ProgramName)
	begin
		set @result = -2
	end
	else
	begin
		update HPHealthcareProgram
		set name = @Programname,
			description = @ProgramDescription,
			phone = @ProgramPhone,
			modifyDate = getutcdate()
		where ID = @programID
						
		set @result = 0
	end	
END