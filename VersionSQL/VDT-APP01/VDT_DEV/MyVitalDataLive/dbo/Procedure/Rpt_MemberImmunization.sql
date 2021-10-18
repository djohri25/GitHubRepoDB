/****** Object:  Procedure [dbo].[Rpt_MemberImmunization]    Committed by VersionSQL https://www.versionsql.com ******/

--Rpt_MemberImmunization S79YR53GW6
--CREATE 
--
CREATE 
Procedure [dbo].Rpt_MemberImmunization 
	@ICENUMBER varchar(15)
As

Set Nocount On

Select convert(varchar(10), DateDone, 101) DateDone, convert(varchar(10), DateDue,101) DateDue,
(Select ImmunName From LookupImmunization 
Where MainImmunization.ImmunId = ImmunId) Vaccination
From MainImmunization Where ICENUMBER = @ICENUMBER