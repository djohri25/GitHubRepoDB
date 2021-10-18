/****** Object:  Function [dbo].[GetChecksum]    Committed by VersionSQL https://www.versionsql.com ******/

/*
 * Calculates checksum of the input string using the following algorithm:
 * - multiply odd numbers by 3 and added to the sum
 * - add even number to the sum
 * - compute mod 10 of the result
 * - subtract result from 10
 * - compute mod 10 of the result
*/
CREATE FUNCTION [dbo].[GetChecksum](@input varchar(15))
RETURNS int
AS
BEGIN
	declare @xStr varchar(15) -- @input string with replaced letters with their ascii representation
	declare @checkSum int
	declare @count int

	select @xStr = '',
		@checkSum = 0,
		@count = 1

	-- Replace every letter with it's ascii code
	while (@count <= len(@input))
	begin
		if( ascii( substring(@input, @count, 1)) >= ascii('A') and
			ascii( substring(@input, @count, 1)) <= ascii('Z'))
		begin
			set @xStr = @xStr + convert(varchar,ascii( substring(@input, @count, 1)))
		end
		else
		begin
			set @xStr = @xStr + substring(@input, @count, 1)
		end

		set @count = @count + 1
	end

	-- Compute checksum
	-- The odd numbers are multiplied by 3 and added to the sum
	set @count = 1
	while (@count <= len(@xStr))
	begin
		set @checkSum = @checkSum + convert(int, substring(@xStr, @count, 1)) * 3
		set @count = @count + 2
	end

	-- The even numbers are simply added to the sum
	set @count = 2
	while (@count <= len(@xStr))
	begin
		set @checkSum = @checkSum + convert(int, substring(@xStr, @count, 1))
		set @count = @count + 2
	end

	-- The modulus of 10 is then taken of the summed total
	set @checkSum = @checkSum % 10

	-- This is subtracted from 10 and the modulus of 10 is taken again.
	set @checkSum = (10 - @checkSum) % 10

	return @checkSum
end