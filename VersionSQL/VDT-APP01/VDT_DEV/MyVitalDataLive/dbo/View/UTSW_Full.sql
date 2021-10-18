/****** Object:  View [dbo].[UTSW_Full]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE VIEW dbo.UTSW_Full
AS
SELECT DISTINCT NPI
FROM         (SELECT     NPI
                       FROM          dbo.UTSW
                       UNION
                       SELECT     NPI
                       FROM         dbo.UTSW_Medicaid
                       UNION
                       SELECT     NPI
                       FROM         dbo.UTSW2
                       UNION
                       SELECT     NPI
                       FROM         dbo.UTSW3) AS UTSW_Full