/****** Object:  Procedure [dbo].[Get_DataIntegrityCheck_CustID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date:
-- Description:	
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================

CREATE Proc [dbo].[Get_DataIntegrityCheck_CustID]
(
	@Cust_ID	int
)
AS
BEGIN
		SET NOCOUNT ON;

		Delete from [VD-RPT01].HPM_Import.dbo.Demog_Compare_Final
		INSERT INTO [VD-RPT01].HPM_Import.dbo.Demog_Compare_Final (Cust_ID, MVDID,MemberID,MemberName,EffectiveDate,TerminationDate,TIN,GroupName,PCP,PCP_Name,RoleID)
		Select  L.cust_id, L.MVDID, L.InsMemberID as MemberID, P.FirstName+', '+ P.LastName as MemberName,I.EffectiveDate, I.TerminationDate, G.GroupName as TIN, G.SecondaryName as GroupName, S.NPI as PCP, ISNULL(S.FirstName,'')+', '+ ISNULL(S.LastName,'') as PCP_Name,S.RoleID
		--INTO #Temp_Destination_Final
		From dbo.MainInsurance I 
		JOIN dbo.Link_MemberId_MVD_Ins L ON L.MVDID = I.ICENUMBER 
		JOIN dbo.MainPersonalDetails P on P.ICENUMBER = L.MVDID
		LEFT JOIN dbo.MainSpecialist S ON I.ICENUMBER = S.ICENUMBER AND S.RoleID = 1 
		LEFT JOIN dbo.MDGroup G on ISNULL(G.GroupName,'') = ISNULL(S.TIN,'') and G.CustID_Import = L.Cust_ID
		WHere L.Cust_ID = @Cust_ID 
		 and L.Active = 1 
		 and ISNULL(P.Firstname,'') <> '' and ISNULL(P.lastname,'') <> ''

END