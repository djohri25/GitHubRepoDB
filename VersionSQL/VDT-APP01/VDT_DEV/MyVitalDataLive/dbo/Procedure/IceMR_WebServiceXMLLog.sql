/****** Object:  Procedure [dbo].[IceMR_WebServiceXMLLog]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_WebServiceXMLLog]  
	@ServiceName varchar(50),
	@ClientIp varchar(25),
	@XMLFile varchar(max)          
AS

SET NOCOUNT ON

	INSERT INTO WebserviceLog (ServiceName, ClientIp, XMLFile, CreationDate)
	VALUES (@ServiceName, @ClientIP, @XmlFile, GETUTCDATE())