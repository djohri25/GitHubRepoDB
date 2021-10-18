/****** Object:  Procedure [dbo].[IceMR_DiseaseSurgUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_DiseaseSurgUpdate]  

@ICENUMBER varchar(15),
@YearDate datetime,
@Condition varchar(50),
@Treatment varchar(150)

AS

SET NOCOUNT ON

INSERT INTO MainSurgeries
(ICENUMBER, YearDate, Condition, Treatment, CreationDate, ModifyDate)
VALUES (@ICENUMBER, @YearDate, @Condition, @Treatment, GETUTCDATE(), GETUTCDATE())