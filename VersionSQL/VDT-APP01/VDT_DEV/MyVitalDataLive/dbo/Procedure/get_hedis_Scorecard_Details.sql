/****** Object:  Procedure [dbo].[get_hedis_Scorecard_Details]    Committed by VersionSQL https://www.versionsql.com ******/

/****** Script for SelectTopNRows command from SSMS  ******/

CREATE procedure [dbo].[get_hedis_Scorecard_Details] (@NPI varchar(100), @GID int, @TID int, @CustID int,  @CompletedFlag int)

as

--get_hedis_Scorecard_Details '1679548721', 4,  0

if @CompletedFlag = 0
BEGIN


SELECT a.MemberID, a.Created, a.MVDID, d.Name + ' (' + d.Abbreviation + ')', e.lastname, e.firstname, e.DOB, isnull(e.InCaseManagement,0),e.HomePhone , 0 as completed 
  FROM MainToDoHEDIS a
  join MainSpecialist b on a.MVDID = b.ICENUMBER
  join Link_MemberId_MVD_Ins c on a.MVDID = c.MVDId
  join LookupHedis d on d.ID = @TID
  join MainPersonalDetails e on a.mvdid = e.ICENUMBER
  where b.RoleID = 1 and b.NPI = @NPI
  and c.Cust_ID = @CustID
  and a.TestLookupID = @TID
  order by e.lastname
  
  END
  ELSE
  BEGIN
  
  SELECT a.MemberID, a.Created, a.MVDID, d.Name + ' (' + d.Abbreviation + ')', e.lastname, e.firstname, e.DOB, isnull(e.InCaseManagement,0),e.HomePhone , 1 as completed 
  FROM MainToDoHEDIS_Done a
  join MainSpecialist b on a.MVDID = b.ICENUMBER
  join Link_MemberId_MVD_Ins c on a.MVDID = c.MVDId
  join LookupHedis d on d.ID = @TID
  join MainPersonalDetails e on a.mvdid = e.ICENUMBER
  where b.RoleID = 1 and b.NPI = @NPI
  and c.Cust_ID = 10
  and a.TestLookupID = @TID
  order by e.lastname
  
  END