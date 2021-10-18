/****** Object:  Procedure [dbo].[GetCOPDFormsInfo]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[GetCOPDFormsInfo]
	@MVDID varchar(20),@CustID varchar(20) =Null
AS
BEGIN
	SET NOCOUNT ON;

	declare @age int, @dob date, @existsAAP bit, @showACT4_11yr bit, @existsACT4_11yr bit,@showACT12yr bit, @existsACT12yr bit, 
	@existAA bit, @showAA bit, @existDIA bit, @showDIA bit, @existPPA bit,@existPEA bit,@existGA bit,@showPEA bit, @showCHF bit,@existCHF bit,
	@existPED bit,@existPEGA bit,@existOBIA bit,@existERIA bit,@existCMFW bit,@existPEGP bit,@existPEPP bit,@existAAF bit,@existACP bit,@existCOPD bit,

--general 
@existGAA bit,@existGDIA bit,@existGPMA bit,@existGGA bit, @existGOBIA bit , @existGERIA bit, @existGCMFW bit,
@existGPEA bit, @existGPED bit,@existGPECHF bit,@existGPEGA bit, @existGPEGP bit,@existGPEPP bit, @existGACP bit
	
	select @existsAAP = 0, @showACT4_11yr = 0, @existsACT4_11yr = 0,@showACT12yr = 0, @existsACT12yr = 0, @existAA =0, @showAA = 0,@existDIA =0, @showDIA =0,@existPPA=0,
	@existPEA = 0,@existCHF = 0,@showCHF = 0,@existGA=0,@existOBIA=0,@existCHF = 0,@existPED = 0,@existERIA=0,@existCMFW=0,@existPEGA = 0,@existPEGP = 0,@existPEPP = 0,
    @existAAF = 0,@existACP = 0, @existCOPD = 0,

--general
@existGAA = 0,@existGDIA = 0,@existGPMA = 0,@existGGA = 0,@existGOBIA = 0,@existGERIA = 0,@existGCMFW = 0,
@existGPEA = 0,@existGPED = 0,@existGPECHF = 0,@existGPEGA = 0,@existGPEGP = 0,@existGPEPP = 0, @existGACP = 0
	
	select @age= dbo.GetAgeInYears(dob,getdate())
	from mainpersonaldetails
	where icenumber = @mvdid
	
	if exists(select top 1 * from FormAsthmaActionPlan where MVDID = @MVDID)
	begin
		set @existsAAP = 1
	end

	if(@age between 4 and 11)
	begin
		select @showACT4_11yr = 1		
	end

	if exists(select top 1 * from FormAsthmaControlTest_4_11yr where MVDID = @MVDID)
	begin
		set @existsACT4_11yr = 1
	end

	if(@age >= 12)
	begin
		select @showACT12yr = 1		
	end

	if exists(select top 1 * from FormAsthmaControlTest_12yr where MVDID = @MVDID)
	begin
		set @existsACT12yr = 1
	end

	--Asthma Assessment
	if exists(select top 1 * from FormAsthmaAssessment where MVDID = @MVDID and CustID = @CustID)
	begin
		set @existAA = 1
	end

	if(@age >0 )
	begin
		select @showAA = 1
	end

-- General Asthma Assessment
IF  exists (SELECT TOP 1 pechf.* from FormAsthmaAssessment pechf where MVDID =@MVDID and CustID=@CustID)  
AND exists (SELECT TOP 1 *  FROM HPAlertNote hn WHERE hn.LinkedFormType = 'GAA' AND MVDID =@MVDID)
BEGIN
		set @existGAA = 1
END

	--Diabetes
	if exists(select top 1 * from FormDiabetesAssessment where MVDID = @MVDID and CustID=@CustID)
	begin
		set @existDIA = 1
	end

-- General Diabetes Assessment
IF  exists (SELECT TOP 1 pechf.* from FormDiabetesAssessment pechf where MVDID =@MVDID and CustID=@CustID)  
AND exists (SELECT TOP 1 *  FROM HPAlertNote hn WHERE hn.LinkedFormType = 'GDIA' AND MVDID =@MVDID)
BEGIN
		set @existGDIA = 1
END

	--SetonPostPartum
	if exists(select top 1 * from FormPostPartumAssessment where MVDID = @MVDID and CustID=@CustID)
	begin
		set @existPPA = 1
	end

-- General PostPartum Assessment
IF  exists (SELECT TOP 1 pechf.* from FormPostPartumAssessment pechf where MVDID =@MVDID and CustID=@CustID)  
AND exists (SELECT TOP 1 *  FROM HPAlertNote hn WHERE hn.LinkedFormType = 'GPMA' AND MVDID =@MVDID)
BEGIN
		set @existGPMA = 1
END

	--SetonGeneralAssessment
	if exists(select top 1 * from FormGeneralAssessment where MVDID = @MVDID and CustID=@CustID)
	begin
		set @existGA = 1
	end

-- General General Assessment
IF  exists (SELECT TOP 1 pechf.* from FormGeneralAssessment pechf where MVDID =@MVDID and CustID=@CustID)  
AND exists (SELECT TOP 1 *  FROM HPAlertNote hn WHERE hn.LinkedFormType = 'GGA' AND MVDID =@MVDID)
BEGIN
		set @existGGA = 1
END

	--SetonOBIntakeAssessment
	if exists(select top 1 * from FormOBIntakeAssessment where MVDID = @MVDID and CustID=@CustID)
	begin
		set @existOBIA = 1
	end

--General OB Intake Assessment
IF  exists (SELECT TOP 1 pechf.* from FormOBIntakeAssessment pechf where MVDID =@MVDID and CustID=@CustID)  
AND exists (SELECT TOP 1 *  FROM HPAlertNote hn WHERE hn.LinkedFormType = 'GOBIA' AND MVDID =@MVDID)
BEGIN
		set @existGOBIA = 1
END

	--SetonERIntakeAssessment
	if exists(select top 1 * from FormERIntakeAssessment where MVDID = @MVDID and CustID=@CustID)
	begin
		set @existERIA = 1
	end

--General ER Intake Assessment
IF  exists (SELECT TOP 1 pechf.* from FormERIntakeAssessment pechf where MVDID =@MVDID and CustID=@CustID)  
AND exists (SELECT TOP 1 *  FROM HPAlertNote hn WHERE hn.LinkedFormType = 'GERIA' AND MVDID =@MVDID)
BEGIN
		set @existGERIA = 1
END

	--SetonCMWFAssessment
	if exists(select top 1 * from FormCMFWAssessment where MVDID = @MVDID and CustID=@CustID)
	begin
		set @existCMFW = 1
	end

--General CMFW Assessment
IF  exists (SELECT TOP 1 pechf.* from FormCMFWAssessment pechf where MVDID =@MVDID and CustID=@CustID)  
AND exists (SELECT TOP 1 *  FROM HPAlertNote hn WHERE hn.LinkedFormType = 'GCMFW' AND MVDID =@MVDID)
BEGIN
		set @existGCMFW = 1
END

	--Patient Education Asthma
	if exists(select top 1 * FROM FormPatientEducationAsthma  where MVDID = @MVDID and CustID=@CustID)
	begin
		set @existPEA = 1
	end

--General Patient Education Asthma
IF  exists (SELECT TOP 1 pechf.* from FormPatientEducationAsthma pechf where MVDID =@MVDID and CustID=@CustID)  
AND exists (SELECT TOP 1 *  FROM HPAlertNote hn WHERE hn.LinkedFormType = 'GPEA' AND MVDID =@MVDID)
BEGIN
		set @existGPEA = 1
END	

	--Patient Education CHF
	if exists(select top 1 * FROM FormPatientEducationCHF  where MVDID = @MVDID and CustID=@CustID)
	begin
		set @existCHF = 1
	end

--General Patient Education CHF
IF  exists (SELECT TOP 1 pechf.* from FormPatientEducationCHF pechf where MVDID =@MVDID and CustID=@CustID)  
AND exists (SELECT TOP 1 *  FROM HPAlertNote hn WHERE hn.LinkedFormType = 'GPECHF' AND MVDID =@MVDID)
BEGIN
		set @existGPECHF = 1
END	

	--Patient Education Diabetes
	if exists(select top 1 * FROM FormPatientEducationDiabetes  where MVDID = @MVDID and CustID=@CustID)
	begin
		set @existPED = 1
	end	
	
--General Patient Education Diabetes
IF  exists (SELECT TOP 1 pechf.* from FormPatientEducationDiabetes pechf where MVDID =@MVDID and CustID=@CustID)  
AND exists (SELECT TOP 1 *  FROM HPAlertNote hn WHERE hn.LinkedFormType = 'GPED' AND MVDID =@MVDID)
BEGIN
		set @existGPED = 1
END

	--Patient Education General Adult
	if exists(select top 1 * FROM FormPatientEducationGeneralAdult  where MVDID = @MVDID and CustID=@CustID)
	begin
		set @existPEGA = 1
	end

--General Patient Education General Adult
IF  exists (SELECT TOP 1 pechf.* from FormPatientEducationGeneralAdult pechf where MVDID =@MVDID and CustID=@CustID)  
AND exists (SELECT TOP 1 *  FROM HPAlertNote hn WHERE hn.LinkedFormType = 'GPEGA' AND MVDID =@MVDID)
BEGIN
		set @existGPEGA = 1
END

	--Patient Education General Pediatrics
	if exists(select top 1 * FROM FormPatientEducationGeneralPediatrics  where MVDID = @MVDID and CustID=@CustID)
	begin
		set @existPEGP = 1
	end

--General Patient Education General Pediatrics
IF  exists (SELECT TOP 1 pechf.* from FormPatientEducationGeneralPediatrics  pechf where MVDID =@MVDID and CustID=@CustID)  
AND exists (SELECT TOP 1 *  FROM HPAlertNote hn WHERE hn.LinkedFormType = 'GPEGP' AND MVDID =@MVDID)
BEGIN
		set @existGPEGP = 1
END

	--Patient Education Post Partum
	if exists(select top 1 * FROM FormPatientEducationPostPartum fpepp  where MVDID = @MVDID and CustID=@CustID)
	begin
		set @existPEPP = 1
	end

--General Patient Education Post Partum
IF  exists (SELECT TOP 1 pechf.* from FormPatientEducationPostPartum  pechf where MVDID =@MVDID and CustID=@CustID)  
AND exists (SELECT TOP 1 *  FROM HPAlertNote hn WHERE hn.LinkedFormType = 'GPEPP' AND MVDID =@MVDID)
BEGIN
		set @existGPEPP = 1
END

	--FormAddendum
	if exists(select top 1 * FROM FormAddendum  where MVDID = @MVDID and CustID=@CustID)
	begin
		set @existAAF = 1
	end

	--FormCOPDCarePlan
	if exists(select top 1 * FROM FormCOPDCarePlan  where MVDID = @MVDID and CustID=@CustID)	
	begin
		set @existCOPD = 1
	end

--General Form COPD Care Plan 
--IF  exists (SELECT TOP 1 * from FormAsthmaCarePlan  where MVDID = @MVDID and CustID=@CustID)  
--AND exists (SELECT TOP 1 *  FROM HPAlertNote hn WHERE hn.LinkedFormType = 'GACP' AND MVDID = @MVDID)
--BEGIN
--		set @existGACP = 1
--END
	
	select @age as 'age',@existsAAP as 'existsAAP', @showACT4_11yr as 'showACT4_11yr', 
		@existsACT4_11yr as 'existsACT4_11yr',@showACT12yr as 'showACT12yr', 
		@existsACT12yr as 'existsACT12yr',
		@existAA as 'existAA', @showAA as 'showAA',
		@existDIA as 'existDIA',
		@existPPA as 'existPPA',@existPEA AS 'existPEA',@existCHF AS 'existCHF',
		@existGA as 'existGA',@existOBIA AS 'existOBIA',@existPED AS 'existPED',
		@existERIA AS 'existERIA', @existCMFW AS 'existCMFW',@existPEGA AS 'existPEGA',@existPEGP AS 'existPEGP',@existPEPP AS 'existPEPP',
		@existAAF AS 'existAAF',@existACP AS 'existACP',@existCOPD AS 'existCOPD',

	@existGAA AS 'existGAA',@existGDIA AS 'existGDIA',@existGPMA AS 'existGPMA',@existGGA AS 'existGGA',@existGOBIA  AS 'existGOBIA',
	@existGERIA AS 'existGERIA',@existGCMFW AS 'existGCMFW',
	@existGPEA AS 'existGPEA',@existGPED AS 'existGPED',@existGPECHF AS 'existGPECHF',@existGPEGA AS 'existGPEGA',@existGPEGP AS 'existGPEGP',@existGPEPP  AS 'existGPEPP',
	@existGACP AS 'existGACP'

END