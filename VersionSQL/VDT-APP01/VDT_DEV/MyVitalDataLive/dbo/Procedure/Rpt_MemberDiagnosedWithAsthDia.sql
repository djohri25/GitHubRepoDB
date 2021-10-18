/****** Object:  Procedure [dbo].[Rpt_MemberDiagnosedWithAsthDia]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].Rpt_MemberDiagnosedWithAsthDia

	@ICENUMBER varchar(15)
AS

declare @diagWithAst varchar(50), @diagWithDia varchar(50)

SET NOCOUNT ON

select 

	Case isnull(am.HasAsthma,0) 
						 when  1 
						 then 'YES'
						 Else 'NO'
      					 End	 as 'DiagnosedWithAsthma',	 

						 Case isnull(am.HasDiabetes,0) 
						   when  1 
				     		then 'YES'
						   Else 'NO'
						 End 
						 as 'DiagnosedWithDiabetes'

FROM Final_ALLMember am WHERE am.mvdid = @ICENUMBER
	--case (select TOP 1 'Y' from MainCondition con where con.ICENUMBER = @ICENUMBER and con.CodeFirst3 = '493') 
	--when 'Y' then 'YES'
	--else 'NO'
	--end as 'DiagnosedWithAsthma',
	--case (select TOP 1 'Y' from MainCondition con where con.ICENUMBER = @ICENUMBER and con.CodeFirst3 = '250') 
	--when 'Y' then 'YES'
	--else 'NO'
	--end as 'DiagnosedWithDiabetes'

--exec	[dbo].Rpt_MemberDiagnosedWithAsthDia

--	@ICENUMBER ='AM575316'