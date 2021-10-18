/****** Object:  Procedure [dbo].[Get_FormPatientEducationGeneralAdultID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormPatientEducationGeneralAdultID]
		@ID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1 fpega.*,
		d.FirstName,
		d.LastName
		  FROM formPatientEducationGeneralAdult fpega 
  INNER JOIN MainPersonalDetails d ON d.ICENUMBER = fpega.MVDID
   LEFT JOIN MainInsurance m ON m.ICENUMBER = fpega.MVDID 
  where ID = @ID
   order by fpega.created desc
END

--EXEC [[[Get_FormPatientEducationGenealAdultID]]] 
--    @ID= 5