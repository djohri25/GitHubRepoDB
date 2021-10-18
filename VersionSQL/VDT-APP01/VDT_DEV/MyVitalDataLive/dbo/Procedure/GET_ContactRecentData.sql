/****** Object:  Procedure [dbo].[GET_ContactRecentData]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		Raghu C
-- Create date: 08/29/19
-- Description:	Get Active MMF 
-- exec Get_ActiveMMF '16577456118885332'
-- =============================================
CREATE PROCEDURE [dbo].[GET_ContactRecentData]
	
	@MVDID varchar(30) null

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SELECT top 1 qExcludePrograms,qHEPSpanishMaterials FROM ARBCBS_Contact_Form where q2program='HEP' and MVDID=@MVDID	order by FormDate desc

	
END