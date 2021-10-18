/****** Object:  Procedure [dbo].[Set_Parkland_Users_Groups]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		BDW
-- Create date: 6/24/2016
-- Description:	add the latest Parkland MD user groups to the MD_Group table 
-- exec dbo.Set_Parkland_Users_Groups
-- =============================================
CREATE PROCEDURE [dbo].[Set_Parkland_Users_Groups]
as
set nocount on

Create table #tin (tin varchar(100))

insert #tin
 -- (1) Found (1013919810) when only using MainSpecialist. 
select distinct(pp.TIN) from [VD-RPT01].[HPM_Import].[dbo].[ParklandProvider] pp 
join dbo.MainSpecialist ms ON ms.tin = pp.tin	
join dbo.Link_MemberId_MVD_Ins mi
on ms.ICENUMBER = mi.MVDId
where 
mi.Cust_ID = 10
and mi.Active = 1
and ms.TIN != '' and ms.TIN is not null
and ms.NPI != '' and ms.NPI is not null
and ms.roleid = 1 
UNION
select distinct(pp.pseudo_TIN) from [VD-RPT01].[HPM_Import].[dbo].[Parklandprovider_PseudoTINS] pp 
join dbo.MainSpecialist ms ON ms.tin = pp.pseudo_TIN--tin	
join dbo.Link_MemberId_MVD_Ins mi
on ms.ICENUMBER = mi.MVDId
where 
mi.Cust_ID = 10
and mi.Active = 1
and ms.TIN != '' and ms.TIN is not null
and ms.NPI != '' and ms.NPI is not null
and ms.roleid = 1

--Add New Groups
Insert MDGroup_Test (GroupName, Active, CreationDate, ModifyDate , IsNoteAlertGroup, CustID_Import)
select TIN,1,GETDATE(),GETDATE(),0, 10 from #tin
where TIN not in 
(select GroupName FROM dbo.MDGroup_Test where CustID_Import = 10)

--DeActivate OLD Groups
Update MDGroup_Test set Active = 0 
where GroupName not in (select TIN from #tin)
and CustID_Import = 10
  
Create table #tinGroup (tin varchar(100))

declare @tin varchar(100), @groupid int

while exists (select * from #tin)
begin
	select top 1 @tin = tin from #tin

	select @groupid = [ID] from [dbo].[MDGroup_Test]
	where GroupName = @tin	
		
	if exists (select  npi
	FROM dbo.MainSpecialist ms
		join dbo.Link_MemberId_MVD_Ins mi on ms.ICENUMBER = mi.MVDId
		where tin = @tin
		and RoleID = 1
		and mi.Active = 1
		and ms.NPI is not null)
	
	BEGIN

		Insert #tinGroup
		select distinct(npi)
		FROM MainSpecialist ms
		join dbo.Link_MemberId_MVD_Ins mi on ms.ICENUMBER = mi.MVDId
		where tin = @tin
		and RoleID = 1
		and mi.Active = 1
		and ms.NPI is not null
		
		delete Link_MDGroupNPI_Test
		where MDGroupID = @groupid
			
		insert Link_MDGroupNPI_Test
		select @groupid, tin from #tinGroup		
		
	END

	delete #tin where tin = @tin
	delete #tinGroup
end

--Add New TIN Users for Parkland (Vital123)
Insert dbo.MDUser_Test (Username,[Password], Active, CreationDate, ModifyDate, AccountName,ForcePasswordReset, Organization )
select GroupName,'Vml0YWwxMjM=',1,GETDATE(),GETDATE(),GroupName,0,'Parkland' from dbo.mdgroup_test
where CustID_Import = 10 and Active = 1
and GroupName not in (select username from dbo.MDUser_Test)

Create Table #TempID ([aID] int ,[gID] int)

Insert #TempID
select distinct a.ID, g.ID
from mdgroup_test g
--join Link_MDGroupNPI_Test l
--on g.ID = l.MDGroupID
join MDUser_Test a
on g.GroupName  = a.username
where g.Active = 1
and g.CustID_Import = 10
order by a.ID

delete Link_MDAccountGroup_Test
where MDGroupID in (select gid from #TempID)
--and MDgroupid not in (16797,16799,16800)  --Any Parkland groups to exclude?

Insert Link_MDAccountGroup_Test (MDAccountID , MDGroupID)
select [aID] ,[gID] from #TempID