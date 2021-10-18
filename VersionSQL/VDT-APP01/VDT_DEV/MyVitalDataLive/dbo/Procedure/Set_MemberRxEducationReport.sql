/****** Object:  Procedure [dbo].[Set_MemberRxEducationReport]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Set_MemberRxEducationReport]
	@MVDID varchar(30),
	@SESSIONID varchar(40),
	@EDUDATE DateTime,
	@REPORT varchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	begin
		BEGIN TRY
			-- Create report record
			INSERT into [dbo].[MemberRxEducationReport] (MVDID, SESSIONID, EDUDT, REPORT)
			VALUES (@MVDID, @SESSIONID, @EDUDATE, @REPORT)
		END TRY
		BEGIN CATCH			
		END CATCH
	end
END