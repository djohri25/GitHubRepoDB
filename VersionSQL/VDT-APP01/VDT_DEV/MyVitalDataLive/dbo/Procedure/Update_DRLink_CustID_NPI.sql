/****** Object:  Procedure [dbo].[Update_DRLink_CustID_NPI]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Update_DRLink_CustID_NPI]

as

Create Table #TempNPIList (NPI varchar(50), CustID int)

Insert #TempNPIList
Select distinct a.NPI, c.Cust_ID  from [Link_MDGroupNPI] a
join MainSpecialist b on a.NPI = b.NPI
join Link_MemberId_MVD_Ins c on b.ICENUMBER = c.MVDId 
and c.Active = 1
order by NPI

Truncate table Lookup_DRLink_NPI_to_CustID

Insert Lookup_DRLink_NPI_to_CustID
Select * from #TempNPIList