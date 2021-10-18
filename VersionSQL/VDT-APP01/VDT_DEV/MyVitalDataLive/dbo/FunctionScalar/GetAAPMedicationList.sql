/****** Object:  Function [dbo].[GetAAPMedicationList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 5/14/2014
-- Description:	Result format: MedID1:HowMuch1,HowOften1|MedID2:HowMuch2,HowOften2|...
-- =============================================
CREATE FUNCTION [dbo].[GetAAPMedicationList]
(
	@FormID int,
	@Zone varchar(20)
)
RETURNS varchar(max)
AS
BEGIN
	declare @result varchar(max)
	
	set @result = ''

--select @FormID = 1, @Zone = 'Green'

	select @result = @result + CONVERT(varchar,medicationID) + ':' + isnull(HowMuch,'') + ',' + ISNULL(howOften,'') + '|'
	from LinkAAPFormMedication f
		inner join LookupAsthmaMedByZone m on f.MedicationID = m.ID
	where FormID = @FormID
		and m.Zone = @Zone

	RETURN @result

END