/****** Object:  Procedure [dbo].[Get_FormPatientEducationAsthmaID]    Committed by VersionSQL https://www.versionsql.com ******/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- Example:	EXEC [dbo].[Get_FormPatientEducationAsthmaID] @CustID = 13, @MVDID = 'DD858319'
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormPatientEducationAsthmaID]
	 @CustID INT
	,@MVDID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1 fpea.*,
	d.FirstName,
	d.LastName
	FROM dbo.FormPatientEducationAsthma fpea 
	INNER JOIN dbo.MainPersonalDetails d ON d.ICENUMBER = fpea.MVDID
	LEFT JOIN dbo.MainInsurance m ON m.ICENUMBER = fpea.MVDID 
	WHERE fpea.CustID = @CustID
	AND fpea.MVDID = @MVDID
	ORDER BY fpea.id DESC
END