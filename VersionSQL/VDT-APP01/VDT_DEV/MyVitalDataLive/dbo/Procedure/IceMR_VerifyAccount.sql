/****** Object:  Procedure [dbo].[IceMR_VerifyAccount]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_VerifyAccount]
	@LastName varchar(50),
	@FirstName varchar(50),
	@Username varchar(50)	

As

	SET NOCOUNT ON

	select count(*) from mainUsername where username = @Username

--	SELECT COUNT(*) FROM MainPersonalDetails WHERE LastName = @LastName AND
--	FirstName = @FirstName AND Email = @Email