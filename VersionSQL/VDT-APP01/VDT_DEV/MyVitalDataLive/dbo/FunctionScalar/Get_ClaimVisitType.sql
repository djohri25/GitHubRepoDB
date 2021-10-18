/****** Object:  Function [dbo].[Get_ClaimVisitType]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/20/2009
-- Description:	Determines visit type based on claims info
-- =============================================
CREATE FUNCTION [dbo].[Get_ClaimVisitType]
(
	@FormType varchar(50),	
	@ProcedureCode varchar(50),
	@BillType varchar(20),				
	@RevCode varchar(50),
	@Pos varchar(50),
	@Taxonomy1 nvarchar(10),
	@Taxonomy2 nvarchar(10),
	@Taxonomy3 nvarchar(10),
	@Taxonomy4 nvarchar(10),
	@Taxonomy5 nvarchar(10)
)
RETURNS varchar(50)
AS
BEGIN
	DECLARE @result varchar(50)

	SET @result = 
		CASE @FormType
			WHEN 'UB92' THEN
				CASE
					WHEN RIGHT(ISNULL(@BillType, '0' ), 1) > 1 THEN
						'IGNORE'
					WHEN RIGHT(@RevCode, 3) LIKE '45%' AND RIGHT(@BillType, 1) = '1' THEN
						'ER'
					ELSE
						'OTHER'
				END
			WHEN 'HCFA' THEN
			(
				CASE 
					--WHEN @Pos IN ('21','23') THEN
					--	'IGNORE'
					WHEN EXISTS
						(	-- Assumption: taxonomy code would exists in first 5 columns. But there are 50 taxonomy clumns for each state
							-- Taxonomy codes for Laboratories
							SELECT	TOP 1 Code
							FROM	LookupLabCodes
							WHERE	Code IN 
									(
										@Taxonomy1, 
										@Taxonomy2, 
										@Taxonomy3,
										@Taxonomy4,
										@Taxonomy5
									)
						) THEN
						'LAB'
					WHEN EXISTS
						(
							-- Taxonomy Code for Suppliers and Transportation Services
							SELECT	TOP 1 Code
							FROM	LookupServiceCodes
							WHERE	Code IN 
									(
										@Taxonomy1, 
										@Taxonomy2, 
										@Taxonomy3,
										@Taxonomy4,
										@Taxonomy5
									)
						) THEN
						'IGNORE'
					ELSE
						'PHYSICIAN'
				END
			)
		END

	RETURN @result
END