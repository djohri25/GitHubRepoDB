/****** Object:  Procedure [dbo].[Get_RecordOutputFormat]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 07/14/2009
-- Description:	Returns the list of formats  
--	MVD record can be exported as (e.g. ccr, csv,mvd)
-- =============================================
CREATE Procedure [dbo].[Get_RecordOutputFormat] 
As

SET NOCOUNT ON

SELECT ID, Name
FROM dbo.LookupOutputFormat