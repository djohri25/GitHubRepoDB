/****** Object:  Procedure [dbo].[Get_LabRequest]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_LabRequest]
@ICENUMBER VARCHAR (15)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT isnull(OrderName,'') as Request,
		OrderingPhysicianLastName as RequestingPhysicianLastName, OrderingPhysicianFirstName as RequestingPhysicianFirstName,
		dbo.FullName(OrderingPhysicianLastName, OrderingPhysicianFirstName, '') as RequestingPhysician,	
		CONVERT(VARCHAR(30),ISNULL(RequestDate,''),101) as RequestDate,
		OrderID, SourceName
	FROM dbo.MainLabRequest 
	WHERE ICENUMBER = @ICENUMBER 
	ORDER BY requestDate desc
END