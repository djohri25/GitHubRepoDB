/****** Object:  Function [dbo].[Get_PrimaryContactName]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 1/6/2009
-- Description:	Returns primary contact's name
-- =============================================
CREATE FUNCTION [dbo].[Get_PrimaryContactName](@IceNumber varchar(15))
RETURNS varchar(50)
AS
BEGIN	
	DECLARE @Result varchar(50)

	declare @PrimContactTypeId int -- ID of the Primary Contact type

	select top 1 @PrimContactTypeId = CaretypeID 
	from LookupCareTypeID 
	where CareTypeName like '%primary contact%'

	
	SELECT TOP 1 @Result = dbo.FullName(LastName, FirstName, MiddleName) 
	FROM MainCareInfo 
	WHERE ICENUMBER = @IceNumber AND CareTypeID = @PrimContactTypeId
	order by modifydate desc

	IF @Result IS NULL SET @Result = ''

	RETURN @Result
END