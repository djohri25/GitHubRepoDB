/****** Object:  Procedure [dbo].[Get_ExportFileName]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 7/15/2009
-- Description:	Returns full name of file containing 
--	exported MVD member record
-- =============================================
CREATE PROCEDURE [dbo].[Get_ExportFileName]
	@MVDID varchar(15),
	@ExportType varchar(50),
	@EMS varchar(50) = null,
	@UserID_SSO varchar(50) = null
AS
BEGIN
	SET NOCOUNT ON;

	declare @filename varchar(100), @temp varchar(15), 
		@firstname varchar(50), @lastname varchar(50),
		@fileExtension varchar(4)

	select @temp = icenumber,
		@firstname = firstname,
		@lastname = lastname
	from mainpersonaldetails
	where icenumber = @mvdid

	select @fileExtension = fileExtension 
	from LookupOutputFormat
	where name = @ExportType

	-- Remove spaces and apostrophes
	select @firstname = dbo.InitCap(replace(replace(@firstname,' ', ''),'''','')),
		@lastname = dbo.InitCap(replace(replace(@lastname,' ', ''),'''',''))

	if(len(isnull(@temp,'')) > 0 AND len(isnull(@fileExtension,'')) > 0 )
	begin
		set @filename = isnull(@firstname + '_','') + isnull(@lastname + '_','')
			+ replace(@ExportType , ' ', '') + '_'
			+ convert(varchar(2),month(getdate()),100) + '_' 
			+ convert(varchar(2),day(getdate()),100)  + '_' 
			+ convert(varchar(4),year(getdate()),100)
			+ '.' + @fileExtension
	end
	
	select @filename
	
	-- Record SP Log
	declare @params nvarchar(1000) = null
	set @params = LEFT('@MVDID=' + ISNULL(@MVDID, 'null') + ';' +
					   '@ExportType=' + ISNULL(@ExportType, 'null') + ';', 1000);
	exec [dbo].[Set_StoredProcedures_Log] '[dbo].[Get_ExportFileName]', @EMS, @UserID_SSO, @params

END