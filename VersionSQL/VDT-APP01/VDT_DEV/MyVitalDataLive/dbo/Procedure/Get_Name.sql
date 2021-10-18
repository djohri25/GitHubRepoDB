/****** Object:  Procedure [dbo].[Get_Name]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_Name]  

@ICENUMBER varchar(15)

as

set nocount on

BEGIN

	SELECT LastName + ', ' + FirstName FROM MainPersonalDetails WHERE ICENUMBER = @ICENUMBER

END