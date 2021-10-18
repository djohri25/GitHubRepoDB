/****** Object:  Procedure [dbo].[Get_XMLWebSerivceLog]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_XMLWebSerivceLog]
	@RecordNumber int,
	@XML varchar(max) OUT
As

SET NOCOUNT ON

	SELECT @XML = XmlFile FROM WebserviceLog WHERE RecordNumber = @RecordNumber