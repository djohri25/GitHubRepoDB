/****** Object:  Procedure [dbo].[ImportCatchError]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		SW
-- Create date: 9/15/2008
-- Description:	Handles exceptions thrown in any of
--		the stored procedures importing MVD records
-- =============================================
CREATE  PROCEDURE [dbo].[ImportCatchError]
	@AddInfo nvarchar(MAX) = NULL
AS
BEGIN	
	SET NOCOUNT ON;

	INSERT INTO ImportErrorLog (ProcedureName, Message, LineNumber, DBName, AdditionalInfo) 
	VALUES (ERROR_PROCEDURE(),ERROR_MESSAGE(),LTrim(Str(ERROR_LINE())), db_name(), @AddInfo)
END