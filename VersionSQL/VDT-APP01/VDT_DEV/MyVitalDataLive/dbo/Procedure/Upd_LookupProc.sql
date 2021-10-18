/****** Object:  Procedure [dbo].[Upd_LookupProc]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 11/10/2009
-- Description:	Updates or creates a new Procedure Lookup record
-- =============================================
CREATE PROCEDURE [dbo].[Upd_LookupProc]
	@Code varchar(15),
	@Desc varchar(100),
	@CodingSystem varchar(10),
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;

    if exists(select code from dbo.LookupUserDefProcedure where code = @code)
	begin
		update LookupUserDefProcedure 
			set Description = @Desc, 
				codingSystem = @CodingSystem,
				Modified = getutcdate(),
				IsProcessed = 0, 
				ProcessedDate = null
		where code = @code			
	end
	else
	begin
		insert into LookupUserDefProcedure (code, Description, codingSystem, created)
		values(@code, @Desc, @CodingSystem, getutcdate())
	end

	set @Result = 0
END