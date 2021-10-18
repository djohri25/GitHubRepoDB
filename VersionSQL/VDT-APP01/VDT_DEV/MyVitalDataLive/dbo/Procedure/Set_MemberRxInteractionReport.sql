/****** Object:  Procedure [dbo].[Set_MemberRxInteractionReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Procedure [dbo].[Set_MemberRxInteractionReport]
	@MVDID varchar(30),
	@SESSIONID varchar(40),
	@RECONDATE DateTime,
	@REPORT varchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	begin
		BEGIN TRY
			-- Create report record
			INSERT into [dbo].[MemberRxInteractionReport] (MVDID, SESSIONID, RECONDT, REPORT)
			VALUES (@MVDID, @SESSIONID, @RECONDATE, @REPORT)
		END TRY
		BEGIN CATCH			
		END CATCH
	end
END