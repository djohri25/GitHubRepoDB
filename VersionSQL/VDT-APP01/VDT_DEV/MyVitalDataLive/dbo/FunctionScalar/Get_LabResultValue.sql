/****** Object:  Function [dbo].[Get_LabResultValue]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Get_LabResultValue]
(
	@resultValue varchar(50),
	@rangeLow varchar(50),
	@rangeHigh varchar(50),
	@returnType varchar(50)		-- inRange or outOfRange
)
RETURNS varchar(50)
AS
BEGIN
	DECLARE @returnVal varchar(50)

	set @returnVal = ''
	
	if(ISNUMERIC(@rangeHigh) = 1 AND ISNULL(@rangeLow,'') = '')
	begin
		set @rangeLow = '0'
	end

	if(ISNUMERIC(@rangeLow) = 1 AND ISNULL(@rangeHigh,'') = '')
	begin
		set @rangeHigh = '9999999'
	end

	if( isnumeric(@resultValue) = 1 AND isnumeric(@rangeLow) = 1 AND isnumeric(@rangeHigh) = 1 )
	begin
		if(		(@returnType = 'InRange'		
				AND ((convert(float,@resultValue) >= convert(float,@rangeLow)
						AND convert(float,@resultValue) <= convert(float,@rangeHigh)
					)
					OR isnull(@rangeLow,'') = '' OR isnull(@rangeHigh,'') = '' OR isnumeric(@rangeLow) = 0 AND isnumeric(@rangeHigh) = 0
					)				
				)
			OR
				(@returnType = 'outOfRange' 
				AND( convert(float,@resultValue) < convert(float,@rangeLow)
					OR convert(float,@resultValue) > convert(float,@rangeHigh)))
		)
		begin
			set @returnVal = @resultValue
		end
	end
	else if(@returnType = 'InRange')
	begin
		set @returnVal = @resultValue
	end

	RETURN @returnVal
END