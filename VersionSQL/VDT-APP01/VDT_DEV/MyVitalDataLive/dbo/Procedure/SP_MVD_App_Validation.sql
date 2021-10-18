/****** Object:  Procedure [dbo].[SP_MVD_App_Validation]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Sylvester Wyrzykowski
-- Create date: 01/07/2008
-- Description:	Check if application identified by ID and password
--				is valid MVD application
-- =============================================
CREATE PROCEDURE [dbo].[SP_MVD_App_Validation] @appID varchar(50), @appPWD varchar(50), @result bit output
	
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @count int

	set @count=0

	select @count=count(*) from MVDApplication 
	where AppID=@appID and AppPWD=@appPWD and AppID is not null and AppPWD is not null

	if @count > 0
	begin 
		select @result = 1
	end
	else
	begin
		select @result = 0
	end
END