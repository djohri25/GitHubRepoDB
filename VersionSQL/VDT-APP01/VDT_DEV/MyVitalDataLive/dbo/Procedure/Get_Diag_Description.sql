/****** Object:  Procedure [dbo].[Get_Diag_Description]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 2/13/2009
-- Description:	Get diagnosis description based on ICD9 code
-- =============================================
CREATE PROCEDURE [dbo].[Get_Diag_Description]
	@OriginalCode varchar(50), 
	@Description varchar(400) OUTPUT, 
	@Type varchar(50) OUTPUT,
	@CodingSystem varchar(50) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SELECT	@Type = null,
			@CodingSystem = null,
			@Description = null

	-- if len < 3 left pad '0's to make it 3 chars
	IF LEN(@originalcode) = 1
		SET @OriginalCode = '00' + @OriginalCode
	ELSE IF(len(@originalcode) = 2)
		SET @OriginalCode = '0' + @OriginalCode

	IF CHARINDEX('.',@OriginalCode,0) > 0 
		--SELECT @Description = MediumDesc, @Type = [Type] from [156465-APP1].[hpm_import].dbo.[LookupICD9] WHERE code = @OriginalCode
		SELECT @Description = RTRIM(MediumDesc), @Type = [Type], @CodingSystem = ICDNo FROM [LookupICD9] WHERE code = @OriginalCode
	ELSE
		-- Note: it takes over 1 second to execute the lookup across the servers because of "Replace(code,'.','') =..."
		--SELECT @Description = MediumDesc, @Type = [Type] FROM [156465-APP1].[hpm_import].dbo.[LookupICD9] WHERE Replace(code,'.','') = @OriginalCode
		SELECT @Description = RTRIM(MediumDesc), @Type = [Type], @CodingSystem = ICDNo FROM [LookupICD9] WHERE CodeNoPeriod = @OriginalCode	

	--IF ISNULL(@Description,'') != ''
	--	-- TODO: change if other coding systems used to look up diagnosis
	--	SET @CodingSystem = 'ICD9'
	--ELSE
	IF ISNULL(@Description,'') = ''	
		SELECT	@Description = Description,
				@CodingSystem = CodingSystem,
				@Type = 'Diseases/Conditions'
		FROM	LookupUserDefDiagnosis
		WHERE	code = @OriginalCode
END