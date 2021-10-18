/****** Object:  Procedure [dbo].[Get_NewCustomers]    Committed by VersionSQL https://www.versionsql.com ******/

/*
	Returns info of new customers in the system to whom the welcome package
	wasn't sent yet
*/

CREATE Procedure [dbo].[Get_NewCustomers]
As

SET NOCOUNT ON

	select icenumber as mvdid,firstname,lastname,isnull(address1,'')+ isnull(' '+address2,'') as address,
		city,state,postalcode as zip, CONVERT(VARCHAR(10),creationdate,101) as signupdate
	from MainPersonalDetails a 
		inner join UserAdditionalInfo b on a.icenumber=b.mvdid
	where (b.isPackageSent='0' or b.isPackageSent is null)
		and a.icenumber not in
		(
			select mvdid from dbo.Link_MemberId_MVD_Ins
		)
	order by creationdate