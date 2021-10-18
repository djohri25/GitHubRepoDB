/****** Object:  Procedure [dbo].[IceMR_AllergiesUpdate]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[IceMR_AllergiesUpdate]  

@ICENUMBER varchar(15),
@AllergenName varchar(25),
@Reaction varchar(150)
          
AS

SET NOCOUNT ON

INSERT INTO MainAllergies
(ICENUMBER, AllergenTypeId, AllergenName, Reaction, CreationDate, ModifyDate)
VALUES (@ICENUMBER, 4, @AllergenName, @Reaction, GETUTCDATE(), GETUTCDATE())