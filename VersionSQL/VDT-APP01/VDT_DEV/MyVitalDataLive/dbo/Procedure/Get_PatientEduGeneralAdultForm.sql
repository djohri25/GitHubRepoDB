/****** Object:  Procedure [dbo].[Get_PatientEduGeneralAdultForm]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_PatientEduGeneralAdultForm]
	@MVDID varchar(20),@CustID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

SELECT TOP 1 pega.*,
		d.FirstName,
		d.LastName FROM FormPatientEducationGeneralAdult pega 
  Left JOIN MainPersonalDetails d ON d.ICENUMBER = pega.MVDID 
  Left JOIN MainInsurance m ON m.ICENUMBER = pega.MVDID 
  where MVDID = @MVDID and CustID=@CustID
  order by pega.ID desc
END
--EXEC Get_PatientEduGeneralAdultForm
--	@MVDID = 'BP279651',
--	@CustID = 1