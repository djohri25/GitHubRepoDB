/****** Object:  Procedure [dbo].[Rpt_GetMemberResponseDetail]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Rpt_GetMemberResponseDetail]  
 @DbName varchar(50),  
 @Customer varchar(50)
  
AS  
  
BEGIN  
 SET NOCOUNT ON;  
  
--declare @DbName varchar(100) = 'MyVitalDataDemo_BK_From_Live',  
--@Customer  varchar(100)='10'  
Declare @sql varchar(max)


set @sql = 'select mpd.Icenumber, lmm.InsMemberId as ''Member MemberID'',mpd.FirstName as ''Member First Name'',mpd.LastName as ''Member Last Name'',hvf.FormDate as ''Date Coach discussed home visit''
,lmm.cust_ID,hvf.q1 as ''Home Visit Offered'',hvf.q1a as ''Member Response to offer of home visit'',hvf.q1b as ''Reason for declining home visit'',hvf.q1c as ''If "other please explain"'',
 hvf.q1d as ''Reason Home visit not offered'',hvf.q1e as ''If "other please explain"''
from [VD-APP01].' + @dbname + '.dbo.MainPersonalDetails mpd join link_memberID_MVD_Ins lmm on mpd.Icenumber = lmm.MVDId 
join [VD-APP01].' + @dbname + '.dbo.ccc_home_Visit_form hvf on lmm.MVDID = hvf.MVDID
where Cust_ID  =' +cast(@Customer as varchar)+ ' order by hvf.FormDate'

exec @sql
End


 --exec [dbo].[Rpt_GetMemberResponseDetail]  
 --@DbName ='MyVitalDataDemo_BK_From_Live',  
 --@Customer ='10'