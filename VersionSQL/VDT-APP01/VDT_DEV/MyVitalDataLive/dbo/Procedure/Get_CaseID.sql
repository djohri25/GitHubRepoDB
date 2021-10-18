/****** Object:  Procedure [dbo].[Get_CaseID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		PPetluri
-- Create date: 2017/06/06
-- Description:	Get CaseID based on the input passed for care space
-- =============================================
CREATE PROCEDURE [dbo].[Get_CaseID] 
 @CustID	INT
,@UserName	VARCHAR(100) -- ex: PPetluri, mgroverccc, pcrouch
,@MVDId	Varchar(35)
,@CaseID	varchar(100) out
,@CaseStatus	varchar(10) out
AS
BEGIN
		SET NOCOUNT ON;

--Select top 1 @CaseID = REPLACE(CONVERT(varchar(10), AF.FormDate, 120),'-','')+CAST(AF.MVDID as char(15))+ StakeholderGroup 
----CAST(YEAR(FormDate) as varchar)+''+CAST(MONTH(FormDate) as varchar)+''+CAST(Day(FormDate) as varchar) 
--, @Casestatus = q4c
--From [dbo].[CCC_CAS_Form] AF JOIN MVDSupportLive.DBO.aspnet_Membership U  ON AF.q5c = U.firstName + ' '+ U.LastName 
--JOIN Link_CCC_UserSHGroup SHG ON SHG.Userid = U.UserID
--JOIN CCC_StakeholderGroup SH ON SH.ID = SHG.SHGroupID
--Where AF.MVDID = @MVDId and U.firstName + ' '+ U.LastName  = @UserName 
--Order by FormDate desc


Declare @GroupName Varchar(200)

Select @GroupName = SH.StakeholderGroup
From MVDSupportLive.DBO.aspnet_Users U  
JOIN Link_CCC_UserSHGroup SHG ON SHG.Userid = U.UserID
JOIN CCC_StakeholderGroup SH ON SH.ID = SHG.SHGroupID
where U.LoweredUserName = LOWER(@UserName)

Select top 1  @CaseID= CaseID
--CAST(YEAR(FormDate) as varchar)+''+CAST(MONTH(FormDate) as varchar)+''+CAST(Day(FormDate) as varchar) 
,  @Casestatus = q4c
From [dbo].[CCC_CAS_Form] AF 
Where AF.MVDID = @MVDId and AF.CaseID like '%'+ @MVDId + '%'+ '%' + @GroupName + '%'
Order by FormDate desc

SET @Casestatus = ISNULL(@Casestatus, 'None')

RETURN
END