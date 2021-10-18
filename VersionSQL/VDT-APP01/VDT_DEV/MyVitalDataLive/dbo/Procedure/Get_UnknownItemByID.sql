/****** Object:  Procedure [dbo].[Get_UnknownItemByID]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 11/9/2009
-- Description:	Returns the info about unknown item which
--	was attempted to import into the system (only item code) 
--  or was already defined by user (info provided by user)
-- =============================================
CREATE PROCEDURE [dbo].[Get_UnknownItemByID]
	@ItemType varchar(50),
	@ItemCode varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	if( @ItemType = 'DIAGNOSIS')
	begin
		if exists(select code from LookupUserDefDiagnosis where code = @itemCode)
		begin
			select code, codingSystem,Description, modified as lastmodified 
			from LookupUserDefDiagnosis 
			where code = @itemCode
		end
		else if exists(select itemcode from ImportErrorUnknownItemLog where itemtype = @itemtype and itemcode = @itemCode)
		begin
			select @ItemCode as code, '' as codingSystem, '' as description, '' as lastmodified
		end
	end
	else if( @ItemType = 'MEDICATION')
	begin
		if exists(select code from LookupUserDefMedication where code = @itemCode)
		begin
			select code, Description, strength, unit,type, modified as lastmodified 
			from LookupUserDefMedication 
			where code = @itemCode
		end
		else if exists(select itemcode from ImportErrorUnknownItemLog where itemtype = @itemtype and itemcode = @itemCode)
		begin
			select @ItemCode as code, '' as description, '' as strength, '' as unit, '' as type, '' as lastmodified
		end
	end
	else if( @ItemType = 'PROCEDURE')
	begin
		if exists(select code from LookupUserDefProcedure where code = @itemCode)
		begin
			select code, codingSystem,Description, modified as lastmodified 
			from LookupUserDefProcedure 
			where code = @itemCode
		end
		else if exists(select itemcode from ImportErrorUnknownItemLog where itemtype = @itemtype and itemcode = @itemCode)
		begin
			select @ItemCode as code, '' as codingSystem, '' as description, '' as lastmodified
		end
	end

END