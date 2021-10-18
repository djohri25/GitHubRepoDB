/****** Object:  Procedure [dbo].[Upd_SubFamilyHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Upd_SubFamilyHistory] 
	@IceNumber varchar(15),
	@FatherAge int,
	@MotherAge int,
	@Anesthesia bit,
	@Note varchar(250),
	@FatherAlive bit,
	@MotherAlive bit,
	@MonthFather VARCHAR(3),
	@MonthMother VARCHAR(3),
    @YearFatherDeceased int, 
	@YearMotherDeceased int,
	@MonthFatherDeceased VARCHAR(3), 
	@MonthMotherDeceased VARCHAR(3)
as
	DECLARE @Count int
	set nocount on
SELECT @Count = COUNT(*) FROM SubFamilyHistory WHERE IceNumber = @IceNumber


IF @Count = 0
	INSERT INTO SubFamilyHistory(IceNumber, FatherAge, MotherAge, Anesthesia, Note, CreationDate, ModifyDate,FatherAlive,MotherAlive,MonthFather, MonthMother,YearFatherDeceased, YearMotherDeceased,MonthFatherDeceased, MonthMotherDeceased) 
	VALUES(@IceNumber, @FatherAge, @MotherAge, @Anesthesia, @Note, GETUTCDATE(), GETUTCDATE(),@FatherAlive,@MotherAlive,@MonthFather, @MonthMother,@YearFatherDeceased, @YearMotherDeceased, @MonthFatherDeceased, @MonthMotherDeceased )

ELSE
	UPDATE SubFamilyHistory
	SET FatherAge = @FatherAge, MotherAge = @MotherAge, Anesthesia = @Anesthesia, Note = @Note, ModifyDate = GETUTCDATE(),FatherAlive = @FatherAlive, MotherAlive = @MotherAlive, MonthFather=@MonthFather, MonthMother=@MonthMother,
	YearFatherDeceased = @YearFatherDeceased, YearMotherDeceased=@YearMotherDeceased, MonthFatherDeceased=@MonthFatherDeceased, 
	MonthMotherDeceased=@MonthMotherDeceased
	WHERE IceNumber = @IceNumber