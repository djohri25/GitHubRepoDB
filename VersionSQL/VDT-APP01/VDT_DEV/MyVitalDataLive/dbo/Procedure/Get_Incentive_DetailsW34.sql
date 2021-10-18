/****** Object:  Procedure [dbo].[Get_Incentive_DetailsW34]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_Incentive_DetailsW34] @CustID int, @TIN varchar(50)

as

declare  @DataYear int --, @CustID int, @TIN varchar(50)

select @datayear = 2014  --, @CustID = 11, @TIN = '760422435'

select a.MemberID, b.lastname, b.firstname, convert(date,a.DOB) as DOB,
case a.IsComplete
when 0 then 'No'
when 1 then 'YES'
end as Complete
, 
Case a.LOB 
when 'M' then 'STAR'
when 'C' then 'CHIP'
end as LOB


from [VD-RPT01].[_All_2014_Final_HEDIS].[dbo].[Final_W34Member] a 
join [VD-RPT01].[Driscoll_HEDIS_2014_Data_2015_MeasurmentYear].dbo.member b 
on a.Memberid = b.Memberid
where data_year = @datayear and custid = @CustID and TIN = @TIN

-- Exec Get_Incentive_Details @CustID = 11, @TIN ='760422435'