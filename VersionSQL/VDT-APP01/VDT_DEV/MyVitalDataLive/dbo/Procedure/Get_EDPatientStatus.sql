/****** Object:  Procedure [dbo].[Get_EDPatientStatus]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:      Tim Thein
-- Create date: 9/22/2009
-- Description: Returns only one row of EDPatientStatus
-- =============================================
CREATE PROCEDURE dbo.Get_EDPatientStatus
	@id INT
AS
BEGIN
	SELECT	s.ID, s.FacilityID, h.Name AS FacilityName, s.MemberID, 
			c.Name AS CustomerName, s.PatientFirstName, s.PatientLastName, 
			dbo.UTCtoET(s.DateVisited) AS DateVisited, s.ModifiedBy
	FROM	EDPatientStatus AS s LEFT JOIN 
			MainEMSHospital AS h ON s.FacilityID = h.ID LEFT JOIN
			HPCustomer AS c ON s.CustID = c.Cust_ID
	WHERE	s.ID = @id
END