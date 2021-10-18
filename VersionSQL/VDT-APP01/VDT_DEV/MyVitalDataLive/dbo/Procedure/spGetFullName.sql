/****** Object:  Procedure [dbo].[spGetFullName]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[spGetFullName]
	@IceNumber varchar(15),
	@Result varchar(300) OUT
As

SET NOCOUNT ON
	SELECT @Result = LastName + ',' + FirstName FROM dbo.MainPersonalDetails 
							WHERE ICENUMBER = @IceNumber