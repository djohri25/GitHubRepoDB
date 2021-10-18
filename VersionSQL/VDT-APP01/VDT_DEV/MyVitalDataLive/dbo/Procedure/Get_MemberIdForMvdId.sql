/****** Object:  Procedure [dbo].[Get_MemberIdForMvdId]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 02/12/2016
-- Description:	This SP returns the Member's (Patient's) id based on provided MVDId and CustId.
-- =============================================
CREATE PROCEDURE [dbo].[Get_MemberIdForMvdId]
	@mvdId varchar(15),
	@CustId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @memberId varchar(20)

	select @memberId = InsMemberId
	from Link_MemberId_MVD_Ins
	where MVDId = @mvdId
		and Cust_ID = @CustId

	select @memberId
    
END