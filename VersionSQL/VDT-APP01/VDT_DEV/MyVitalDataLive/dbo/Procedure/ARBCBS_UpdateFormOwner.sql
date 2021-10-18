/****** Object:  Procedure [dbo].[ARBCBS_UpdateFormOwner]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:	
-- Create date: 08/12/2019
-- Modified date: 
-- Change: 
-- Description:	Update form owner in ABCBS_MemberManagement_Form.
-- =============================================
CREATE PROCEDURE [dbo].[ARBCBS_UpdateFormOwner]
	@Id bigint = NULL
AS
BEGIN

	SET NOCOUNT ON;
	
	declare @Owner varchar(100), @GroupID int, @MVDID varchar(30), @DocId bigint

	--set the owner value to current owner of task
	select top 1 @Owner=TAL.[Owner], @MVDID = T.MVDID
	from Task T
	join TaskActivityLog TAL on T.Id = TAL.TaskId
	where T.Id = @Id
	order by TAL.ID desc
	
--check if owner value is 'Admission AutoQ' then use new logic and set value for groupid
   IF @Owner = 'Admission AutoQ' 
	BEGIN 
		   SET @GroupID = (
		   SELECT CAST(ID as int) FROM HPAlertGroup WHERE NAME =
		   (SELECT 
		   case when FM.CMORGREGION in('WALMART','ABB','JBHUNT','TYSON','EXCHNG','ASEPSE') THEN 'Nurse Nav Admission'
		   when CMORGREGION IN('BARB_EAST','BARB_WEST') AND COMPANYKEY in(2,306,2864,11794,16932,17517) then 'Nurse Nav Admission'
		   --when CMORGREGION in('FEP') THEN 'FEP (NO AD GROUP YET)'			--disabled right now since no HpAlertGroup exist
		   --when CMORGREGION IN('MEDICAREADV') THEN 'MA (NO AD GROUP YET)'		--disabled right now since no HpAlertGroup exist
		   else 'Clinical Support' 
		   end as NewQ
		   FROM FinalMember FM 
		   WHERE MVDID = @MVDID)
		   --where MVDID = '161243522285478987' and CustID = 16)
		     )
		   --print @GroupId
		Set @Owner = (SELECT 
		   case when FM.CMORGREGION in('WALMART','ABB','JBHUNT','TYSON','EXCHNG','ASEPSE') THEN 'Nurse Nav Admission'
		   when CMORGREGION IN('BARB_EAST','BARB_WEST') AND COMPANYKEY in(2,306,2864,11794,16932,17517) then 'Nurse Nav Admission'
		   --when CMORGREGION in('FEP') THEN 'FEP (NO AD GROUP YET)'			--disabled right now since no HpAlertGroup exist
		   --when CMORGREGION IN('MEDICAREADV') THEN 'MA (NO AD GROUP YET)'		--disabled right now since no HpAlertGroup exist
		   else 'Clinical Support' 
		   end as NewQ
		   FROM FinalMember FM 
		   WHERE MVDID = @MVDID)
		   --where MVDID = '161243522285478987' and CustID = 16
		   
		--TaskActivityLog insert new record for GroupID from previous statement
		BEGIN
			INSERT INTO TaskActivityLog 
				   ([TaskId]
		           ,[Owner]
		           ,[DueDate]
		           ,[StatusId]
		           ,[PriorityId]
		           ,[CreatedDate]
		           ,[CreatedBy]
		           ,[ReasonForUpdate]
				   ,GroupID)
			select top 1 TaskId, 
						 @Owner, --New Owner group
						 DueDate, 
						 StatusId, 
						 PriorityId, 
						 GETUTCDATE(), 
						 CreatedBy, 
						 ReasonForUpdate, 
						 @GroupID --New Owner GroupId
			from TaskActivityLog
			where TaskId = @Id
			order by ID desc
		
		--select * from TaskActivityLog where Owner = 'Admission AutoQ'
		
		END
		
		-- GET DOCID FROM MemberReferral table 
		IF EXISTS(
			SELECT DocID FROM MemberReferral
			WHERE TaskID = @Id AND DocID IS NOT NULL 
			--AND TaskSource <> 'Maternity Enrollment'
		 )
		BEGIN
			SELECT @DocId = DocID FROM MemberReferral
			WHERE TaskID = @Id AND DocID IS NOT NULL
			--AND TaskSource <> 'Maternity Enrollment' 

			UPDATE ABCBS_MemberManagement_Form
			SET ReferralOwner = @Owner
			where ID = @DocId
		END
	
	END
END