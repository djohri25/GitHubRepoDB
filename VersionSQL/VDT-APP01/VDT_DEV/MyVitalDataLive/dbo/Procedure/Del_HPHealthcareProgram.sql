/****** Object:  Procedure [dbo].[Del_HPHealthcareProgram]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Del_HPHealthcareProgram]
	@ProgramID int,
	@Result int out
AS
BEGIN
	SET NOCOUNT ON;

	set @result = -1

	if exists (select id from dbo.HPHealthcareProgram where id = @ProgramID)
	begin
		delete from HPHealthcareProgram where id = @programID
		set @result = 0
	end	
END