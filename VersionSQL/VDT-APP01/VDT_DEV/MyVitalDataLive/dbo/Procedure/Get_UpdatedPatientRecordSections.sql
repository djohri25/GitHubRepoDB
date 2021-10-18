/****** Object:  Procedure [dbo].[Get_UpdatedPatientRecordSections]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 8/13/2009
-- Description:	Returns list of patient's record sections
--	(medication, surgery, personal info, etc) which were updated after the date
--	provided as an argument 
-- =============================================
CREATE PROCEDURE [dbo].[Get_UpdatedPatientRecordSections]
	@MvdID varchar(15),
	@TimeStamp datetime
AS
BEGIN
	SET NOCOUNT ON;

	declare @tempResult table (sectionName varchar(50), lastUpdate datetime)

	declare @tempUpdDate datetime

	--	PERSONAL INFO
	select @tempUpdDate = 
		max (case isnull(ModifyDate,'')
			when '' then CreationDate
			else ModifyDate
		end)
	from MainPersonalDetails
	where icenumber = @MvdID and (modifyDate > @TimeStamp or creationDate > @TimeStamp)

	if(@tempUpdDate is not null)
	begin
		insert into @tempResult (sectionName,lastUpdate) values ('Personal', @tempUpdDate)
		set @tempUpdDate = null
	end

	--	ALLERGY
	select @tempUpdDate = 
		max (case isnull(ModifyDate,'')
			when '' then CreationDate
			else ModifyDate
		end)
	from MainAllergies
	where icenumber = @MvdID and (modifyDate > @TimeStamp or creationDate > @TimeStamp)

	if(@tempUpdDate is not null)
	begin
		insert into @tempResult (sectionName,lastUpdate) values ('Allergy', @tempUpdDate)
		set @tempUpdDate = null
	end

	--	MEDICATION
	select @tempUpdDate = 
		max (case isnull(ModifyDate,'')
			when '' then CreationDate
			else ModifyDate
		end)
	from MainMedication
	where icenumber = @MvdID and (modifyDate > @TimeStamp or creationDate > @TimeStamp)

	if(@tempUpdDate is not null)
	begin
		insert into @tempResult (sectionName,lastUpdate) values ('Medication', @tempUpdDate)
		set @tempUpdDate = null
	end

	--	SURGERY
	select @tempUpdDate = 
		max (case isnull(ModifyDate,'')
			when '' then CreationDate
			else ModifyDate
		end)
	from MainSurgeries
	where icenumber = @MvdID and (modifyDate > @TimeStamp or creationDate > @TimeStamp)

	if(@tempUpdDate is not null)
	begin
		insert into @tempResult (sectionName,lastUpdate) values ('Surgery', @tempUpdDate)
		set @tempUpdDate = null
	end

	--	INSURANCE
	select @tempUpdDate = 
		max (case isnull(ModifyDate,'')
			when '' then CreationDate
			else ModifyDate
		end)
	from MainInsurance
	where icenumber = @MvdID and (modifyDate > @TimeStamp or creationDate > @TimeStamp)

	if(@tempUpdDate is not null)
	begin
		insert into @tempResult (sectionName,lastUpdate) values ('Insurance', @tempUpdDate)
		set @tempUpdDate = null
	end

	--	CONTACT
	select @tempUpdDate = 
		max (case isnull(ModifyDate,'')
			when '' then CreationDate
			else ModifyDate
		end)
	from MainCareInfo
	where icenumber = @MvdID and (modifyDate > @TimeStamp or creationDate > @TimeStamp)

	if(@tempUpdDate is not null)
	begin
		insert into @tempResult (sectionName,lastUpdate) values ('Contact', @tempUpdDate)
		set @tempUpdDate = null
	end

	--	CONDITION
	select @tempUpdDate = 
		max (CreationDate)
	from MainCondition
	where icenumber = @MvdID and creationDate > @TimeStamp

	if(@tempUpdDate is not null)
	begin
		insert into @tempResult (sectionName,lastUpdate) values ('Condition', @tempUpdDate)
		set @tempUpdDate = null
	end

	--	ED VISIT
	select @tempUpdDate = 
		max (Created)
	from EdVisitHistory
	where icenumber = @MvdID and Created > @TimeStamp

	if(@tempUpdDate is not null)
	begin
		insert into @tempResult (sectionName,lastUpdate) values ('EDVisit', @tempUpdDate)
		set @tempUpdDate = null
	end

	select sectionName, lastUpdate from @tempResult
END