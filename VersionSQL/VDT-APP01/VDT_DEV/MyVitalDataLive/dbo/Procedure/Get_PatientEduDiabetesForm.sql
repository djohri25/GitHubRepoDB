/****** Object:  Procedure [dbo].[Get_PatientEduDiabetesForm]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_PatientEduDiabetesForm]
	@MVDID varchar(20),@CustID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

SELECT TOP 1 ped.*,
		d.FirstName,
		d.LastName FROM FormPatientEducationDiabetes ped 
  Left JOIN MainPersonalDetails d ON d.ICENUMBER = ped.MVDID 
  Left JOIN MainInsurance m ON m.ICENUMBER = ped.MVDID 
  where MVDID = @MVDID and CustID=@CustID
  order by ped.ID desc
END
--EXEC Get_PatientEduDiabetesForm
--	@MVDID = 'BP279651',
--	@CustID = 1