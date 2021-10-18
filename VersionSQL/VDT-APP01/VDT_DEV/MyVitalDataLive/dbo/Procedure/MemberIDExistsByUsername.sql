/****** Object:  Procedure [dbo].[MemberIDExistsByUsername]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[MemberIDExistsByUsername]
@MemberID varchar(100), @Username varchar(500)

AS

IF EXISTS(
SELECT DISTINCT mm.* FROM MDUser_Member mm
JOIN MainSpecialist ms ON mm.MVDID = ms.ICENUMBER
 WHERE  mm.MemberID = @MemberID 
 AND ms.RoleID=1
 AND mm.DoctorUsername = @Username
) 
 BEGIN
  SELECT 1
END
ELSE
BEGIN
  SELECT -1
END

--EXEC [MemberIDExistsByUsername] @username = 'dchpbeta3' , @memberid = '626106452'