/****** Object:  Procedure [dbo].[Get_FormPatientEducationDiabetesID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormPatientEducationDiabetesID]
		@ID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1 fped.*,
		d.FirstName,
		d.LastName
		  FROM formPatientEducationDiabetes fped 
  INNER JOIN MainPersonalDetails d ON d.ICENUMBER = fped.MVDID
   LEFT JOIN MainInsurance m ON m.ICENUMBER = fped.MVDID 
  where ID = @ID
   order by fped.created desc
END

--EXEC [[Get_FormPatientEducationDiabetesID]] 
--    @ID= 5