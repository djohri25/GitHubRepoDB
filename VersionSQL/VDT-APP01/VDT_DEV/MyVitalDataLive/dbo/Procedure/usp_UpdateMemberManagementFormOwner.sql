/****** Object:  Procedure [dbo].[usp_UpdateMemberManagementFormOwner]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:	
-- Create date: 08/12/2019
-- Modified date: 
-- Change: 
-- Description:	Update form owner in ABCBS_MemberManagement_Form.
-- =============================================
Create PROCEDURE [dbo].[usp_UpdateMemberManagementFormOwner]
	@ReferralId bigint = NULL
AS
BEGIN

	SET NOCOUNT ON;
	
	declare @Owner varchar(100), @MVDID varchar(30), @DocId bigint

	--set the owner value to current owner of task
	select @DocId=DocID
	from MemberReferral
	where ID = @ReferralId

	select @MVDID = MVDID, @Owner = ReferralOwner
	from ABCBS_MemberManagement_Form
	where ID = @DocId
	
--check if owner value is 'Admission AutoQ' then use new logic and set value for groupid
   IF @Owner = 'Admission AutoQ' 
	BEGIN 
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
		   
		
			UPDATE ABCBS_MemberManagement_Form
			SET ReferralOwner = @Owner
			where ID = @DocId
	END
END