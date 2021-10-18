/****** Object:  Procedure [dbo].[Rpt_MemberPatientHP]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Rpt_MemberPatientHP] 
	@IceNumber varchar(15)
As

	if exists( select mvdid from Link_MemberId_MVD_Ins where mvdid = @icenumber)
	begin
		declare @HPName varchar(100), @InsMemberID varchar(50)

		select @HPName = '',
			@InsMemberID = ''

		select @HPName = Name,
			@InsMemberID = mi.insMemberID
		from dbo.Link_MVDID_CustID mi
			inner join hpCustomer c on mi.cust_id = c.cust_id
		where mvdid = @icenumber

		select @HPName as 'HPName',
			@InsMemberID as 'MemberID',
			dbo.FormatPhone(HomePhone) as 'MemberPhone'
		from dbo.MainPersonalDetails
		where icenumber = @IceNumber
	end

	