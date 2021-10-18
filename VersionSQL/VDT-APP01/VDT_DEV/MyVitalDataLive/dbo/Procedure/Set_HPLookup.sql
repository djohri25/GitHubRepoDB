/****** Object:  Procedure [dbo].[Set_HPLookup]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 10/22/2008
-- Description:	Inserts record int a lookup table
-- =============================================
CREATE PROCEDURE [dbo].[Set_HPLookup]
	@Code varchar(10),
	@Desc1 varchar(1000),
	@Desc2 varchar(1000)
AS
BEGIN
	SET NOCOUNT ON;

	insert into HP_SV1 (code, description1, description2)
	values (@Code, @Desc1, @Desc2)
END