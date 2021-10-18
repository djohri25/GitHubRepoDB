/****** Object:  Procedure [dbo].[Get_SubFamilyHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_SubFamilyHistory] 
	@IceNumber varchar(15)
as

	SET NOCOUNT ON

	DECLARE @Count int
	
	SELECT	@Count = COUNT(*) FROM SubFamilyHistory WHERE ICENUMBER = @IceNumber
	IF @Count = 0
		INSERT INTO SubFamilyHistory (ICENUMBER, CreationDate, ModifyDate) 
		VALUES (@IceNumber, GETUTCDATE(), GETUTCDATE())

	SELECT FatherAge, MotherAge, Anesthesia, Note, dbo.CheckedAns(Anesthesia) AS IsAnes,
		FatherAlive, MotherAlive, MonthFather, MonthMother,YearFatherDeceased, 
		YearMotherDeceased,MonthFatherDeceased, MonthMotherDeceased
	FROM SubFamilyHistory WHERE ICENUMBER = @IceNumber