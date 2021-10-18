/****** Object:  Procedure [dbo].[Get_CustomerType]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_CustomerType]
	@UserName varchar(50)=null
AS
BEGIN

SET NOCOUNT ON;

SELECT TOP 1
	CASE WHEN HPName='Driscoll' THEN 'Driscoll Health Plan.'
	ELSE NULL 
	END AS HPName, CustID
FROM MDUser_Member where DoctorUsername= @UserName
 
END