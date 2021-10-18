/****** Object:  Procedure [dbo].[Get_LookupGenericCodes_BK_09112020]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 09/13/2016
-- Description:	Get Lookup_Generic_Code data based on customerId and CodeTypeId
-- =============================================
create PROCEDURE [dbo].[Get_LookupGenericCodes_BK_09112020]
	@customerId int = null,
	@codeTypeId int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if (@codeTypeId is null and @customerId is null) --Gets all codes
		begin
			select lgc.CodeID, lgc.CodeTypeID, lgc.Cust_ID, lgc.Label, lgc.Label_Desc, lgct.CodeType
			from Lookup_Generic_Code lgc
			join Lookup_Generic_Code_Type lgct on lgc.CodeTypeID = lgct.CodeTypeID
			where lgc.IsActive = 1
		end
	else if (@codeTypeId is null and @customerId is not null) --Gets all codes for provided customerId. Also include codes where cust_id is null.
		begin
			select lgc.CodeID, lgc.CodeTypeID, lgc.Cust_ID, lgc.Label, lgc.Label_Desc, lgct.CodeType
			from Lookup_Generic_Code lgc
			join Lookup_Generic_Code_Type lgct on lgc.CodeTypeID = lgct.CodeTypeID
			where (lgc.Cust_ID = @customerId or lgc.Cust_ID is null)
				and lgc.IsActive = 1
		end
	else if (@customerId is null and @codeTypeId is not null) --Gets all codes for provided codeTypeId regardless of customer.
		begin
			select lgc.CodeID, lgc.CodeTypeID, lgc.Cust_ID, lgc.Label, lgc.Label_Desc, lgct.CodeType
			from Lookup_Generic_Code lgc
			join Lookup_Generic_Code_Type lgct on lgc.CodeTypeID = lgct.CodeTypeID
			where lgc.CodeTypeID = @codeTypeId
				and lgc.IsActive = 1
		end
	else
		begin
			select lgc.CodeID, lgc.CodeTypeID, lgc.Cust_ID, lgc.Label, lgc.Label_Desc, lgct.CodeType
			from Lookup_Generic_Code lgc
			join Lookup_Generic_Code_Type lgct on lgc.CodeTypeID = lgct.CodeTypeID
			where lgc.CodeTypeID = @codeTypeId
				and (lgc.Cust_ID = @customerId or lgc.Cust_ID is null)
				and lgc.IsActive = 1
		end
END