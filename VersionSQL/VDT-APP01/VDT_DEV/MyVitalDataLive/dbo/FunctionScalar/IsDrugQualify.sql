/****** Object:  Function [dbo].[IsDrugQualify]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Function [dbo].[IsDrugQualify]
(
	@MVDID	VARCHAR(40), @RXName		varchar(100)
)
RETURNS INT
AS
BEGIN
	Declare @NDCCode Table (NDCCode	varchar(100))
	Declare @Value	INT

	--INSERT INTO @NDCCode 
	--Select Distinct ndc_code from Link_HEDIS_Medication Where (brand_name like '%'+@RxName+'%' OR generic_product_name like '%'+@RxName+'%' OR [Description] like '%'+@RxName+'%')

	--INSERT INTO @NDCCode
	--Select Distinct Code as NDCCode From MainMedication Where ICENUMBER = @MVDID and RxDrug like '%'+@RxName+'%'

	--Select @Value = 1 from MainMedication M JOIN Link_MemberId_MVD_Ins L ON L.MVDID = M.ICENUMBER 
	--WHere M.ICENUMBER = @MVDID  and Code in (select * from @NDCCode) GROUP BY ICENUMBER HAVING COUNT(*) >= 1
	
	Select @Value = 1 from MainMedication M JOIN Link_MemberId_MVD_Ins L ON L.MVDID = M.ICENUMBER 
	WHere M.ICENUMBER = @MVDID  and Code in (
											Select Distinct ndc_code from Link_HEDIS_Medication Where (brand_name like '%'+@RxName+'%' OR generic_product_name like '%'+@RxName+'%' OR [Description] like '%'+@RxName+'%')
											UNION
											Select Distinct Code as NDCCode From MainMedication Where ICENUMBER = @MVDID and RxDrug like '%'+@RxName+'%')
											GROUP BY ICENUMBER HAVING COUNT(*) >= 1

RETURN ISNULL(@Value,0)
END