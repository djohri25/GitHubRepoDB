/****** Object:  Procedure [dbo].[Get_AsthmaMedByZone]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/12/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_AsthmaMedByZone]
	@zone varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	select ID, Name
	from LookupAsthmaMedByZone
	where Zone = @zone
END