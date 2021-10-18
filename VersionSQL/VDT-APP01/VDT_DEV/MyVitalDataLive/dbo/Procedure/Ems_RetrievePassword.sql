/****** Object:  Procedure [dbo].[Ems_RetrievePassword]    Committed by VersionSQL https://www.versionsql.com ******/

create Procedure [dbo].[Ems_RetrievePassword]
	@Email varchar(50),
	@SecureQu int,
	@SecureAn varchar(50)
	
	
AS

	SET NOCOUNT ON

	SELECT COUNT(*) FROM MainEMS WHERE Email = @Email
	AND SecureQu = @SecureQu AND SecureAn = @SecureAn