/****** Object:  Procedure [dbo].[Get_Medication_Description]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 2/13/2009
-- Description:	Get medication description based on
-- National Drug Code (NDC)
-- Changes:	08/18/2017	Marc De Luca	Added SELECT TOP (1).  Cleaned up proc
-- =============================================
CREATE PROCEDURE [dbo].[Get_Medication_Description] 
	 @NDCCode varchar(50)
	,@Description varchar(100) output
	,@CodingSystem varchar(50) output	-- e.g. NDC, RxNorm
	,@MedType char output				-- 'O' Over The Counter (OTC)	-- 'R' Prescribed
	,@IgnoreFlag bit output				-- Set to 1 if med is in Ignore list
AS

BEGIN

	SET NOCOUNT ON;

	DECLARE @labelerCode VARCHAR(10), @productCode VARCHAR(4)

	-- Set default values
	SELECT @Description = NULL, @CodingSystem = NULL, @MedType = NULL, @IgnoreFlag = '0'

	IF(LEN(ISNULL(@NDCCode,'')) > 8)
	BEGIN
		IF EXISTS (SELECT ndc FROM dbo.LookupNDC_Ignore WHERE NDC = @NDCCode)
		-- Ignore med on import
		BEGIN
			SELECT @Description = 'Unknown', @MedType = 'O', @IgnoreFlag = '1'
		END
		ELSE
		BEGIN
			SELECT TOP (1)
				 @Description = UPPER(Product.PROPRIETARYNAME + ' ' + Product.DOSAGEFORMNAME + ' ' + Product.ROUTENAME) 
				,@MedType = CASE Product.PRODUCTTYPENAME WHEN 'HUMAN PRESCRIPTION DRUG' THEN 'R' ELSE 'O' END
			FROM dbo.LookupMedicationNDC_Package Package
			JOIN dbo.LookupMedicationNDC_Product Product ON Package.PRODUCTID = Product.PRODUCTID AND Package.PRODUCTNDC = Product.PRODUCTNDC
			WHERE[NDC11] = @NDCCode

			IF( LEN(ISNULL(@Description,'')) = 0)
			BEGIN
				-- Search Other Medication table with includes many Over The Counter Drugs (OTC)
				-- Get original values
				SELECT @labelerCode = LEFT(@NDCCode,5), @productCode = SUBSTRING(@NDCCode,6,4)

				SELECT @Description = RTRIM(ProductName), @MedType = DrugTypeIndicator 
				FROM dbo.LookupNDCOther
				WHERE labelercode = @labelerCode 
				AND productcode = @productCode

				IF(LEN(ISNULL(@Description,'')) > 0)
				BEGIN
					SELECT @MedType = case isnull(@MedType,'') WHEN '' THEN NULL WHEN '1' THEN 'R' WHEN '2' THEN 'O' ELSE NULL END
				END
			END

			IF( LEN(ISNULL(@Description,'')) > 0)
			BEGIN
				SET @CodingSystem = 'NDC'
			END
			ELSE
				-- Check user defined medications
				SELECT @Description = Description, @MedType = [type]
				FROM dbo.LookupUserDefMedication
				WHERE code = @NDCCode
		END

	END

END