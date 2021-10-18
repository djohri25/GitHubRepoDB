/****** Object:  Procedure [dbo].[Get_HPHealthcareProgramByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_HPHealthcareProgramByID]
	@ProgramID varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	select cust_id as customerId, Name, Description 
		,dbo.FormatPhone(Phone) As Phone
		,Substring(Phone,1,3) As PhoneArea
		,Substring(Phone,4,3) As PhonePrefix
		,Substring(Phone,7,4) As PhoneSuffix 
	from dbo.HPHealthcareProgram
	where id = @programID
END