/****** Object:  Procedure [dbo].[Get_PlaceList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_PlaceList]
@Language BIT = 1
As

Set Nocount On
IF(@Language = 1)
	BEGIN -- 1 = english
		Select PlacesTypeID, PlacesTypeName From  LookupPlacesTypeID 
		Order By PlacesTypeName
	END
ELSE
	BEGIN -- 0 = spanish
		Select PlacesTypeID, PlacesTypeNameSpanish PlacesTypeName From  LookupPlacesTypeID 
		Order By PlacesTypeNameSpanish
	END