/****** Object:  Procedure [dbo].[uspGetMobileMember]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 06/14/2020
-- Description:	Search active member based on input field for mobile member registration.
-- exec uspGetMobileMember @MemberId = '50000000201', @MemberName = 'NATHAN B HARRIS', @Last4SSN = '3702', @DOB = '1976-02-21'
-- exec uspGetMobileMember @MemberId = '50000000201', @MemberName = 'nAthAn HARris', @Last4SSN = '3702', @DOB = '1976-02-21'
-- exec uspGetMobileMember @MemberId = 'XDR50000000201', @MemberName = 'NATHAN B HARRIS', @Last4SSN = '3702', @DOB = '1976-02-21'
-- =============================================
CREATE PROCEDURE [dbo].[uspGetMobileMember]
	@MemberId varchar(30),
	@MemberName varchar(200),
	@Last4SSN varchar(4),
	@DOB date
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
--		fm.MemberID = @MemberId
		(
			fm.MemberID = @MemberID
			OR
			fm.MemberID = SUBSTRING( @MemberID, 4, LEN( @MemberID ) )
		)
	and (fm.DateOfBirth = @DOB or fm.DateOfBirth is null)
	and SUBSTRING(ISNULL(fm.SSN, ''),6,4) = @Last4SSN
	and (
			CHARINDEX(LTRIM(RTRIM(ISNULL(fm.MemberFirstName, ''))) , @MemberName) > 0 or
			CHARINDEX(LTRIM(RTRIM(ISNULL(fm.MemberLastName, ''))), @MemberName) > 0 
			--or CHARINDEX(fm.MemberMiddleName, @MemberName) > 0
		)
END