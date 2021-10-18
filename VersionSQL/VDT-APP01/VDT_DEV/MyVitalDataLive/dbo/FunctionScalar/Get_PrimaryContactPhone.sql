/****** Object:  Function [dbo].[Get_PrimaryContactPhone]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 1/6/2009
-- Description:	Returns primary contact's phone
-- =============================================
CREATE FUNCTION [dbo].[Get_PrimaryContactPhone](@IceNumber varchar(15))
RETURNS varchar(50)
AS
BEGIN	
	DECLARE @Result varchar(50),@HPhone varchar(20),@CPhone varchar(20),@OPhone varchar(20)

	declare @PrimContactTypeId int -- ID of the Primary Contact type

	select top 1 @PrimContactTypeId = CaretypeID 
	from LookupCareTypeID 
	where CareTypeName like '%primary contact%'

	
	SELECT TOP 1 @HPhone = PhoneHome, @CPhone = PhoneCell, @OPhone = PhoneOther
	FROM MainCareInfo 
	WHERE ICENUMBER = @IceNumber AND CareTypeID = @PrimContactTypeId
	order by modifydate desc

	if(len(isnull(@HPhone,'')) > 0)
	begin
		set @Result = @HPhone
	end
	else if(len(isnull(@CPhone,'')) > 0)
	begin
		set @Result = @CPhone
	end 
	else if(len(isnull(@OPhone,'')) > 0)
	begin
		set @Result = @OPhone
	end
	else
	begin
		set @Result = ''
	end

	select @Result = dbo.FormatPhone(@Result)	

	RETURN @Result
END