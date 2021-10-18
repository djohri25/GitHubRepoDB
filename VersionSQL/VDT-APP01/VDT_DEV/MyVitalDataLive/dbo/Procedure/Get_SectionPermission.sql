/****** Object:  Procedure [dbo].[Get_SectionPermission]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_SectionPermission] 
	@SectionID int,
	@ICENUMBER varchar(15)
AS

SET NOCOUNT ON
DECLARE @IsPermitted bit

SELECT @IsPermitted = IsPermitted FROM SectionPermission
WHERE SectionId = @SectionId AND ICENUMBER = @ICENUMBER

IF @IsPermitted IS NULL SET @IsPermitted = 0

SELECT @IsPermitted AS IsPermitted