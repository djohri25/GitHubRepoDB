/****** Object:  Procedure [dbo].[Get_HasItemsOnRecord]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 8/8/2008
-- Description:	Returns a flag indicating whether the account has any items 
--		of the specific category (e.g. Medication)
-- Parameters:
--		@ICENUMBER - member identifier
--		@Category - category name, e.g. Medications, Allergies, Contacts, Insurances
-- =============================================
CREATE Procedure [dbo].[Get_HasItemsOnRecord]  
@ICENUMBER varchar(15),
@Category varchar(20)

as
set nocount on

BEGIN	 
	declare @result int
	set @result = 0

	if(@Category = 'allergies') 
	begin
		if EXISTS (Select ICENUMBER from MainAllergies where ICENUMBER = @ICENUMBER	)
			set @result = 1;
	end
	else if(@Category = 'medications') 
	begin
		if EXISTS (Select ICENUMBER from MainMedication where ICENUMBER = @ICENUMBER	)
			set @result = 1;
	end
	else if(@Category = 'contacts') 
	begin
		if EXISTS (Select ICENUMBER from MainCareInfo where ICENUMBER = @ICENUMBER	)
			set @result = 1;
	end
	else if(@Category = 'insurances') 
	begin
		if EXISTS (Select ICENUMBER from MainInsurance where ICENUMBER = @ICENUMBER	)
			set @result = 1;
	end
	else
	begin
		select @result = -1;
	end

	select  @result	
END