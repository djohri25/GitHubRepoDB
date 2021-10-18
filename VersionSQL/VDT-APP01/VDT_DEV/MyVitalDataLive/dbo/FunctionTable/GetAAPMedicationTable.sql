/****** Object:  Function [dbo].[GetAAPMedicationTable]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE FUNCTION [dbo].[GetAAPMedicationTable]
	(
		@MedicationList varchar(max) -- Format: MedName1:HowMuch1,HowOften1|MedName2:HowMuch2,HowOften2|...
	)
RETURNS @result TABLE
	(
		Name varchar(50),
		HowMuch varchar(50),
		HowOften varchar(50)
	)
AS
BEGIN
	declare @temp table(id int identity(1,1), med varchar(1000))
	declare @med varchar(1000), @id int, @medName varchar(50), @howMuch varchar(50), @HowOften varchar(50)
	
	if(isnull(@MedicationList,'') <> '')
	begin
		insert into @temp(med)
		select * from dbo.Split(@MedicationList,'|')

		while exists(select top 1 * from @temp)
		begin
			select top 1 @med = med, @id = id,
				@medName = null, @howmuch = null, @howoften = null
			from @temp
					
			if(isnull(@med,'') <> '')
			begin	
				select @medName = SUBSTRING(@med,0,charindex(':',@med,0))

				select @howMuch = SUBSTRING(@med,charindex(':',@med,0)+1, charindex(',',@med,0)-charindex(':',@med,0)-1)

				select @howOften = SUBSTRING(@med,charindex(',',@med,0)+1,LEN(@med) - charindex(',',@med,0))						
				
				if(isnull(@medName,'') <> '')
				begin
					insert into @result(name,howmuch,howoften)
					values(@medName,@howmuch,@howoften)
				end
			end
			
			delete from @temp where id = @id
		end
	end
	RETURN
END