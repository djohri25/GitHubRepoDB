/****** Object:  Procedure [dbo].[ImportErrorUnknownItem]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 2/11/2009
-- Description:	Handles unknown item code which was found in import data
-- =============================================
CREATE PROCEDURE [dbo].[ImportErrorUnknownItem]
	@ClaimRecordID nvarchar(50),
	@ItemCode nvarchar(50),
	@ItemType nvarchar(50),
	@MVDId varchar(15)
AS
BEGIN
	SET NOCOUNT ON;

	declare @curDate varchar(50)
	set @curDate = convert(varchar,getutcdate())

--	Insert into [156465-APP1].[hpm_import].dbo.ImportErrorUnknownItemLog
	Insert into ImportErrorUnknownItemLog
		(ClaimRecordID,ItemCode,ItemType,MVDId,DBName)
	values(@ClaimRecordID, @ItemCode, @ItemType, @MVDId,db_name())

	-- Send email
--	EXEC SendMailOnUnknownImportItem
--		@RecordId = @ClaimRecordID,
--		@MVDId = @MVDId,
--		@ItemCode = @ItemCode,
--		@ItemType = @ItemType,
--		@Date = @curDate
END