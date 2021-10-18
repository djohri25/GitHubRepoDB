/****** Object:  Procedure [dbo].[Get_PatientEduAsthmaForm]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_PatientEduAsthmaForm]
	@MVDID varchar(20),@CustID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

SELECT TOP 1 pea.*,
		d.FirstName,
		d.LastName FROM FormPatientEducationAsthma pea 
  Left JOIN MainPersonalDetails d ON d.ICENUMBER = pea.MVDID 
  Left JOIN MainInsurance m ON m.ICENUMBER = pea.MVDID 
  where MVDID = @MVDID and CustID=@CustID
  order by pea.ID desc
END