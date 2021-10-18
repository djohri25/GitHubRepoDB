/****** Object:  Procedure [dbo].[Get_RaceNames]    Committed by VersionSQL https://www.versionsql.com ******/

Create Procedure [dbo].[Get_RaceNames]
@Language BIT = 1
AS
Set Nocount On
IF(@Language = 1)
	BEGIN -- 1 = english
		SELECT        RaceID, RaceName
		FROM            LookupRace
		ORDER BY RaceID		
	END
ELSE
	BEGIN -- 0 = spanish
		SELECT        RaceID, RaceNameSpanish AS RaceName
		FROM            LookupRace
		ORDER BY RaceID		
	END