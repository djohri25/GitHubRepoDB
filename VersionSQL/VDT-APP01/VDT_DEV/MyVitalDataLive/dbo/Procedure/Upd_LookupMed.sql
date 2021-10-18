/****** Object:  Procedure [dbo].[Upd_LookupMed]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 11/10/2009
-- Description:	Updates or creates a new Medication Lookup record
-- =============================================
CREATE PROCEDURE [dbo].[Upd_LookupMed]
	@Code varchar(15),
	@Desc varchar(100),
	@Strength varchar(10),
	@Unit varchar(50),
	@Type varchar(10),
	@Result int output
AS
BEGIN
	SET NOCOUNT ON;

    if exists(select code from dbo.LookupUserDefMedication where code = @code)
	begin
		update LookupUserDefMedication 
			set Description = @Desc, 
				strength = @strength,
				unit = @unit,
				type = @type,
				Modified = getutcdate(),
				IsProcessed = 0, 
				ProcessedDate = null	
		where code = @code			
	end
	else
	begin
		insert into LookupUserDefMedication (code, Description, strength, unit, type, created)
		values(@code, @Desc, @strength, @unit, @type, getutcdate())
	end

	set @Result = 0
END