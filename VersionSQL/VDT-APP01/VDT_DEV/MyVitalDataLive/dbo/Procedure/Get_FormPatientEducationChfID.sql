/****** Object:  Procedure [dbo].[Get_FormPatientEducationChfID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormPatientEducationChfID]
		@ID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1 fpea.*,
		d.FirstName,
		d.LastName
		  FROM formPatientEducationCHF fpea 
  INNER JOIN MainPersonalDetails d ON d.ICENUMBER = fpea.MVDID
   LEFT JOIN MainInsurance m ON m.ICENUMBER = fpea.MVDID 
  where ID = @ID
   order by fpea.created desc
END

--EXEC [Get_FormPatientEducationChfID] 
--    @ID= 5