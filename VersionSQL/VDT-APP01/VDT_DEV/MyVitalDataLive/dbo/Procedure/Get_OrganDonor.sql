/****** Object:  Procedure [dbo].[Get_OrganDonor]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_OrganDonor] 
@Language BIT = 1
As

Set Nocount On
IF(@Language = 1)
	BEGIN -- 1 = english
		Select OrganDonorID, OrganDonorName From LookupOrganDonorTypeID
			Order By OrganDonorID 
	END
ELSE
	BEGIN -- 0 = spanish
		Select OrganDonorID, OrganDonorNameSpanish OrganDonorName From LookupOrganDonorTypeID
			Order By OrganDonorID 
	END