/****** Object:  Procedure [dbo].[uspGetExistingBroadcastPopulation]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 09/22/2020
-- Description:	Get broadcast population for existing broadcast.
-- exec uspGetExistingBroadcastPopulation 1
-- =============================================
CREATE PROCEDURE [dbo].[uspGetExistingBroadcastPopulation]
	@BroadcastId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--declare @mbrNotRegisteredLkupId int;

	--select @mbrNotRegisteredLkupId = CodeID from Lookup_Generic_Code where CodeTypeID = 28 and Label = 'MbrNotRegistered'

    select 
		MVDID,
		BroadcastStatusId,
		Convert(bit,Isnull([IsMemberMobileRegistered],0)) as IsMemberRegistered
		--CONVERT(bit, 
		--	case 
		--		when BroadcastStatusId = @mbrNotRegisteredLkupId then 0
		--		else 1
		--	end) as IsMemberRegistered
	from Link_BroadcastMember
	where BAId = @BroadcastId
END