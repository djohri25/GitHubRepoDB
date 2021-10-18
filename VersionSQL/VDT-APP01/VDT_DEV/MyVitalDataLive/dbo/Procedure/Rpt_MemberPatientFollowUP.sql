/****** Object:  Procedure [dbo].[Rpt_MemberPatientFollowUP]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Rpt_MemberPatientFollowUP]
	@IceNumber varchar(15)
As
	declare @temp table (insID varchar(50))
		
	-- In case multiple Insurance Member IDs are mapped to one mvdid for example after merging 2 records
	insert into @temp
	select insmemberID
	from Link_MemberId_MVD_Ins
	where MVDId = @IceNumber

	-- There is a chance multiple insMember IDs are mapped to same MVDID as a result of merging
	select distinct Major, Minor 
	from dbo.MainToDoHEDIS_New
	where 
		(
			major not like '%access %' 
			or Major like '%Access to PCP'
		)
		and 
		memberID in
		(
			select insID from @temp
			--select insMemberId
			--from Link_MemberId_MVD_Ins
			--where mvdid = @IceNumber		
		)