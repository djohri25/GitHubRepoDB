/****** Object:  Procedure [dbo].[spGetUpdatedByContactInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[spGetUpdatedByContactInfo]
	@IceNumber varchar(15),
	@Result varchar(300) OUT
As

SET NOCOUNT ON
	SELECT @Result = ISNULL(ISNULL(HomePhone, (ISNULL(CELLPhone,WorkPHONE))), '') FROM dbo.MainPersonalDetails 
							WHERE ICENUMBER = @IceNumber