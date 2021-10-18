/****** Object:  Procedure [dbo].[Get_MemberCaseHistory]    Committed by VersionSQL https://www.versionsql.com ******/

/*
example:
execute [dbo].[Get_MemberCaseHistory] '16', '161364597FA6B'
changes:
0721 luna  change UTC time to date
10/07 added new column for o/p
*/

CREATE PROCEDURE [dbo].[Get_MemberCaseHistory] 
               @CustID INT,
               @MVDID VARCHAR(20) 
               
AS
BEGIN
               -- SET NOCOUNT ON added to prevent extra result sets from
               -- interfering with SELECT statements.
               SET NOCOUNT ON;
		
			  BEGIN 
				   SELECT
								  [CCA_CaseId] as CaseID,
								  '' as ConsentDate,
								  '' as ActivatedDate,
								   '' as Activated,						 							  
								  cast([CaseCreateDate] as date) as CaseCreateDate,
								  cast([CaseCloseDate] as date) as CaseCloseDate,
								  [CaseProgram] as CaseProgram,
								   '' as CaseCategory,
									'' as CaseType,
								  '' as Auditable,                  
								  [NetworkID] as CaseOwner                        
				   FROM [dbo].[VitalData_CCACaseAssignmentHistory] CCA
				   JOIN FinalMember M on M.MemberID = CCA.MemberId -- for new structures
				   -- JOIN [dbo].[Link_MemberId_MVD_Ins] M on M.InsMemberId = CCA.MemberId -- for old structures
				   WHERE M.MVDID = @MVDID
				   UNION
				   SELECT
								  MMF.[CaseID] as CaseID,
								  cast(MMF.[q2ConsentDate] as datetime) as ConsentDate,
								   cast(MCPI.[ActivatedDate] as datetime) as ActivatedDate,
								  MCPI.[Activated] as Activated,
								  cast(MMF.[q1CaseCreateDate] as datetime) as CaseCreateDate,
								  cast(MMF.[q1CaseCloseDate] as datetime) as CaseCloseDate,
								  [CaseProgram] as CaseProgram,
								   MMF.[q5CaseCategory] as CaseCategory,
                                  MMF.[q5CaseType] as CaseType,
								  [AuditableCase] as Auditable,
								  [q1CaseOwner] as CaseOwner                        
				   FROM [dbo].[ABCBS_MemberManagement_Form] MMF
				    full Join [dbo].[MainCarePlanMemberIndex] MCPI on MMF.CarePlanID = MCPI.CarePlanID
				   WHERE MMF.MVDID = @MVDID
				   AND (IsNull(MMF.CaseID,'n/a') != 'n/a' and MMF.CaseID > '')
				   ORDER BY CaseCreateDate DESC
			  END			  
			 
END