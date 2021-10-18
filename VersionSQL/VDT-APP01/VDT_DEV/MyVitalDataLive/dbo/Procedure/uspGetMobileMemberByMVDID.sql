/****** Object:  Procedure [dbo].[uspGetMobileMemberByMVDID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 06/14/2020
-- Description:	Search active member based on MVDID for mobile app.
-- =============================================
Create PROCEDURE [dbo].[uspGetMobileMemberByMVDID]
	@MVDID varchar(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select top 1
		fm.MemberID as MemberId,
		--case when fe.active=0 then '-1' else fm.mvdid end testmvdid,
		fm.mvdid as MVDID,
		fm.MemberFirstName as FirstName,
		fm.MemberMiddleName as MiddleName,
		fm.MemberLastName as LastName,
		fm.DateOfBirth as DOB,
		fm.SSN as SSN,
		fe.membereffectivedate as EffectiveDate,
		fe.memberterminationdate as TerminationDate,
		CAST(ISNULL(fe.Active, 0) as bit) as IsActive
		from finalmember fm
		cross apply
		(
		    select distinct
				e.memberid,
				first_value(e.membereffectivedate) over (partition by e.memberid order by e.membereffectivedate desc ) membereffectivedate,
				first_value(e.memberterminationdate) over (partition by e.memberid order by e.membereffectivedate desc ) memberterminationdate,
				first_value(case when e.membereffectivedate<=getdate() and e.memberterminationdate>=getdate() then 1 else 0 end)
				    over (partition by e.memberid order by e.membereffectivedate desc ) Active
		    from
				finaleligibility e
		    where
				e.memberid = fm.memberid
		) fe
	where 
		fm.MVDID = @MVDID
END