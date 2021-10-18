/****** Object:  Function [dbo].[Get_AlertDiagnosisMatch]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 11/23/2009
-- Description:	Returns info whether the member 
--	matches Diagnosis criteria of the particular 
--	alerting rule
-- =============================================
CREATE FUNCTION [dbo].[Get_AlertDiagnosisMatch]
(
	@Rule_ID int,
	@MvdID varchar(20)
)
RETURNS bit
AS
BEGIN

	DECLARE @result bit, @tempDiagID int, @tempDiagName varchar(50)
	declare @tempRuleDiag table (id int, name varchar(50))

	set @result = 0

	insert into @tempRuleDiag(id,name)
	select d.diagnosis_ID, d.name from dbo.Link_HPRuleDiagnosis rd
		inner join hpDiagnosis d on rd.diagnosis_ID = d.diagnosis_ID
	where rd.rule_id = @rule_id

	-- No diagnosis were selected from the list so consider match as true
	if not exists(select id from @tempRuleDiag)
	begin
		set @result = 1
	end

	-- Check diagnosis selected from the list
	while @result = 0 and exists(select id from @tempRuleDiag)
	begin
		select top 1 @tempDiagID = id,
			@tempDiagName = name
		from @tempRuleDiag

		if(charindex('X',@tempDiagName) <> 0)
		begin
			select @tempDiagName = replace(replace(@tempDiagName,'X',''),'.','')

			if exists( select recordNumber from MainCondition where icenumber = @mvdid and left(code,len(@tempDiagname)) = @tempDiagName)
			begin
				set @result = 1		
			end
		end
		else
		begin
			set @tempDiagname = replace(@tempDiagname,'.','')

			if exists( select recordNumber from MainCondition where icenumber = @mvdid and code = @tempDiagName)
			begin
				set @result = 1		
			end			
		end		
		delete from @tempRuleDiag 
		where id = @tempDiagID
	end

	-- If AllOther was selected, check if any Diagnosis exists for that member
	if @result = 0 and exists (select allOtherDiagnosis from hpAlertRule where Rule_ID = @Rule_ID and isnull(allOtherDiagnosis,0) = 1)
		and exists (select recordNumber from MainCondition where icenumber = @mvdid)
	begin
		set @result = 1
	end 

	RETURN @result
END