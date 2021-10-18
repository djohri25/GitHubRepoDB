/****** Object:  Procedure [dbo].[Get_HPMemberNoteStatus]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 7/25/2011
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Get_HPMemberNoteStatus]
	@CustID int
AS
BEGIN
	SET NOCOUNT ON;

	select ID,Name from LookupHPMemberStatus 
END