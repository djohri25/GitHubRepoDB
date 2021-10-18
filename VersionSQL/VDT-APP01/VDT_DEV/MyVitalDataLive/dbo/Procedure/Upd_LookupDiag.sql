/****** Object:  Procedure [dbo].[Upd_LookupDiag]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 11/10/2009
-- Description:	Updates or creates a new Diagnosis Lookup record
-- =============================================
CREATE PROCEDURE [dbo].[Upd_LookupDiag]
	@Code varchar(6),
	@Desc varchar(35),
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;

    if exists(select code from dbo.LookupUserDefDiagnosis where code = @code)
	begin
		update LookupUserDefDiagnosis set Description = @Desc, Modified = getutcdate(),IsProcessed = 0, ProcessedDate = null
		where code = @code
	end
	else
	begin
		insert into LookupUserDefDiagnosis (code, codingSystem, Description, created)
		values(@code, 'ICD9', @Desc, getutcdate())
	end

	set @Result = 0
END