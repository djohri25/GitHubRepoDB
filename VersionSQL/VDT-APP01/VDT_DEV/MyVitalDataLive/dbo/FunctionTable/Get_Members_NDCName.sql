/****** Object:  Function [dbo].[Get_Members_NDCName]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Function dbo.Get_Members_NDCName
(
	@Cust_ID	INT, @MVDID	VARCHAR(30), @RXName		varchar(100)
)
RETURNS @result TABLE (MVDID varchar(50))
AS
BEGIN
	Declare @NDCCode Table (NDCCode	varchar(100))
	

	INSERT INTO @NDCCode 
	Select Distinct ndc_code from Link_HEDIS_Medication Where (brand_name like '%'+@RxName+'%' OR generic_product_name like '%'+@RxName+'%' OR [Description] like '%'+@RxName+'%')

	INSERT INTO @NDCCode
	select * from [dbo].[Get_NDCCodes_from_RXName](@RXName)

	IF @MVDID = ''
	BEGIN
		INSERT INTO @result
		Select Distinct ICENUMBER as MVDID from MainMedication M JOIN Link_MemberId_MVD_Ins L ON L.MVDID = M.ICENUMBER 
		WHere L.CUst_ID = @Cust_ID and Code in (select * from @NDCCode) GROUP BY ICENUMBER HAVING COUNT(*) >= 1
	END
	ELSE 
	BEGIN
		INSERT INTO @result
		Select Distinct ICENUMBER as MVDID from MainMedication M JOIN Link_MemberId_MVD_Ins L ON L.MVDID = M.ICENUMBER 
		WHere L.CUst_ID = @Cust_ID and M.ICENUMBER = @MVDID  and Code in (select * from @NDCCode) GROUP BY ICENUMBER HAVING COUNT(*) >= 1
	END
RETURN
END