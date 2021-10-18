/****** Object:  Procedure [dbo].[Get_LooupMemberNoteForm]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
------------------------------------------------
--	User		Date		Updates
------------------------------------------------
--	dpatel		07/26/2017	Added DocFormGroup field to return as a result
-- =============================================
CREATE PROCEDURE [dbo].[Get_LooupMemberNoteForm]
AS
BEGIN
	SET NOCOUNT ON;

    SELECT [FormName]
		,[ProcedureName]
		,[Type]
		,[Active]
		,[Cust_IDs]
		,[DocFormGroup]  
		,[DocFormType]
		,[LockingCategory]
		,[FormController]
	FROM [dbo].[LookupCS_MemberNoteForms]
	where Active = 1
	Order By DocFormGroup, FormName
 END