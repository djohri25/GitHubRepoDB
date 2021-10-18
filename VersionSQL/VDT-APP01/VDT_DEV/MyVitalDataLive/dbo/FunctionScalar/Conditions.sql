/****** Object:  Function [dbo].[Conditions]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[Conditions](@IceNumber varchar(15))
RETURNS varchar(100)
AS
BEGIN
	IF dbo.HasConditions(@IceNumber) <> 'Yes'
		RETURN ''
		
	declare  @tempDisease varchar(100), 
		@otherTotal int -- not major conditions count

	set @tempDisease=''
	set @otherTotal = 0

	--select @IceNumber='T64FL85HG2'

	DECLARE @Result varchar(100), @Disease varchar(25), @Condition varchar(25)
	SET @Result = ''
		
	DECLARE ResultCur CURSOR FOR
	SELECT distinct DiseaseId FROM MainDiseaseCond WHERE
		ICENUMBER = @IceNumber

	OPEN ResultCur
	FETCH NEXT FROM ResultCur INTO @Disease
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Check if other condition exist than Major
		select @otherTotal = count(*) from MainDiseaseCond a inner join LookupDiseaseCond b on a.DiseaseCondId = b.DiseaseCondId
			WHERE ICENUMBER = @IceNumber and (b.isMajor <> '1' or b.isMajor is null)


		select @tempDisease = @tempDisease + 
			isnull(
				(Select top 1 b.DiseaseCondName from LookupDiseaseCond b 
					where b.DiseaseCondId = a.DiseaseCondId  and b.isMajor = '1') + ','
				,'')
		from MainDiseaseCond a
		WHERE ICENUMBER = @IceNumber and DiseaseId = @Disease 
		
		--select @tempDisease

		if( len(@tempDisease)> 0)
		begin
			select @Result = @Result + @tempDisease
		end

		select @tempDisease=''

		FETCH NEXT FROM ResultCur INTO @Disease

	END

	CLOSE ResultCur
	DEALLOCATE ResultCur

	-- Add if other condition exists than Major
	if (len(@Result) > 0 and @otherTotal > 0)
	begin
		select @Result=@Result + ' Other on record'
	end 

	-- Remove ',' if exist as a last character
	if(len(@Result) > 0 and right(@Result, 1)=',')
	begin
		select @Result = substring(@Result,1,len(@Result)-1)
	end

	--select @Result
	RETURN @Result
END