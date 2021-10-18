/****** Object:  Procedure [dbo].[Get_FormPatientEducationPostPartumID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_FormPatientEducationPostPartumID]
		@ID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT top 1 fpega.*,
		d.FirstName,
		d.LastName
		  FROM formPatientEducationPostPartum fpega 
  INNER JOIN MainPersonalDetails d ON d.ICENUMBER = fpega.MVDID
   LEFT JOIN MainInsurance m ON m.ICENUMBER = fpega.MVDID 
  where ID = @ID
   order by fpega.created desc
END

--EXEC [[[Get_FormPatientEducationPostPartumID]]] 
--    @ID= 5