/****** Object:  Procedure [dbo].[Get_PatientEduGeneralPediatricsForm]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_PatientEduGeneralPediatricsForm]
	@MVDID varchar(20),@CustID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

SELECT TOP 1 pegp.*,
		d.FirstName,
		d.LastName FROM FormPatientEducationGeneralPediatrics pegp 
  Left JOIN MainPersonalDetails d ON d.ICENUMBER = pegp.MVDID 
  Left JOIN MainInsurance m ON m.ICENUMBER = pegp.MVDID 
  where MVDID = @MVDID and CustID=@CustID
  order by pegp.ID desc
END
--EXEC Get_PatientEduGeneralPediatricsForm
--	@MVDID = 'BP279651',
--	@CustID = 1