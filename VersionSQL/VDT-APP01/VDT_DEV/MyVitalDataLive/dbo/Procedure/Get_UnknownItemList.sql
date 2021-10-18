/****** Object:  Procedure [dbo].[Get_UnknownItemList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 11/9/2009
-- Description:	Returns the list of unknown items which
--	were attempted to import into the system
-- =============================================
CREATE PROCEDURE [dbo].[Get_UnknownItemList]
	@ItemType varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	if( @ItemType = 'DIAGNOSIS')
	begin
		select distinct ItemCode 
		from ImportErrorUnknownItemLog
		where ItemType = @itemType and isProcessed = 0
			and ItemCode not in
			(
				select code from LookupUserDefDiagnosis
			)
		order by itemCode
	end
	else if( @ItemType = 'MEDICATION')
	begin
		select distinct ItemCode 
		from ImportErrorUnknownItemLog
		where ItemType = @itemType and isProcessed = 0
			and ItemCode not in
			(
				select code from LookupUserDefMedication
			)
		order by itemCode
	end
	else if( @ItemType = 'PROCEDURE')
	begin
		select distinct ItemCode 
		from ImportErrorUnknownItemLog
		where ItemType = @itemType and isProcessed = 0
			and ItemCode not in
			(
				select code from LookupUserDefProcedure
			)
		order by itemCode
	end

END