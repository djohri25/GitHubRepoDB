/****** Object:  Function [dbo].[SkipNotifications]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 6/16/2009
-- Description:	Check if ApplicationID is qualified to
--	skip alert notifications when looking up patient record
-- =============================================
CREATE FUNCTION [dbo].[SkipNotifications]
(
	@ApplicationID varchar(50), @RequestType varchar(50)
)
RETURNS bit
AS
BEGIN
	DECLARE @Result bit

	set @Result = 0

	if exists (select a.AppID 
		from MVDApplication a
			inner join MVDApplicationSpec s on a.AppID = s.ApplicationID
		where a.AppID = @ApplicationID AND Type = @RequestType)
	begin
		set @Result = 1
	end
	else
	begin
		set @Result = 0
	end
	
	RETURN @Result
END