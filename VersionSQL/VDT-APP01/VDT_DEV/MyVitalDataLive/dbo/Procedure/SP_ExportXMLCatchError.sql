/****** Object:  Procedure [dbo].[SP_ExportXMLCatchError]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[SP_ExportXMLCatchError]
AS
BEGIN
	
	SET NOCOUNT ON;

	INSERT INTO ExportXMLErrorMsg (ErrorInfo) VALUES ('Procedure:' + isnull(ERROR_PROCEDURE(),'') + ' - '    
	+ isnull(ERROR_MESSAGE(),'') + ' Line: ' + isnull(LTrim(Str(ERROR_LINE())),'') )

END