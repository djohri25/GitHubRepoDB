/****** Object:  Procedure [dbo].[Get_ImmnuList]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_ImmnuList]

as

Set NoCount On

SELECT * FROM LookupImmunization
ORDER BY ImmunName