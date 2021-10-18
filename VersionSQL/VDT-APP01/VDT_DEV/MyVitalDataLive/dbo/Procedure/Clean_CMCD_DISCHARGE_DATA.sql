/****** Object:  Procedure [dbo].[Clean_CMCD_DISCHARGE_DATA]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		BDW
-- Create date: 4/4/2016
-- Description:	To handle parsing errors on DOB and Admit_Date before insert.
-- 07/17/2017 Marc De Luca Removed Database.dbo.Tablename call to just dbo.TableName
-- =============================================

-- exec Clean_CMCD_DISCHARGE_DATA '3452295','83735562','CARRIZALESROBINSON,CHRISTOPH1E','0R/7','D/1S1HON 3/10/16 12:29 am','EMERGENCY','610469840','P- post op problem on March 3rd','KURIAN, DARLENE ANNIE','Home or Self Care','999-999-9999','DAL EMERGENCY' 

CREATE PROCEDURE [dbo].[Clean_CMCD_DISCHARGE_DATA]
	@MRN varchar(255),
	@CSN varchar(255),
	@PATIENT_NAME varchar(255),
	@DOB  varchar(255),
	@ADMIT_DATE varchar(255),
	@CLASS varchar(255),
	@MEDICAIDE_NUMBER varchar(255),
	@VISIT_REASON varchar(255),
	@PCP varchar(255),
	@DISCHARGE_DISPOSITION varchar(255),
	@PATIENTS_HOME_NUMBER varchar(255),
	@Type varchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF isdate(@DOB) <> 1
	BEGIN
		SELECT @DOB = m.DOB  
		FROM dbo.Link_MemberId_MVD_Ins l
		INNER JOIN dbo.MainPersonalDetails m ON m.ICENUMBER = l.MVDid
		WHERE l.InsMemberId = @MEDICAIDE_NUMBER		
	END

	IF @PATIENTS_HOME_NUMBER = '999-999-9999'
	BEGIN
		SELECT @PATIENTS_HOME_NUMBER = m.HomePhone  
		FROM dbo.Link_MemberId_MVD_Ins l
		INNER JOIN dbo.MainPersonalDetails m ON m.ICENUMBER = l.MVDid
		WHERE l.InsMemberId = @MEDICAIDE_NUMBER		
	END

	IF isdate(@ADMIT_DATE) <> 1
	BEGIN
		IF ISDATE(SUBSTRING(@ADMIT_DATE,CHARINDEX(' ',@ADMIT_DATE),50))=1  
			BEGIN
				SELECT @ADMIT_DATE = SUBSTRING(@ADMIT_DATE,CHARINDEX(' ',@ADMIT_DATE),50)
			END
		
			else

			BEGIN
				SET @ADMIT_DATE = null
			END
	END

	Insert Into CMCD_DISCHARGE_DATA 
	([GUID], [MRN], [CSN], [PATIENT_NAME], [DOB], [ADMIT_DATE], [CLASS], 
	[MEDICAIDE_NUMBER], [VISIT_REASON], [PCP], [DISCHARGE_DISPOSITION], [PATIENTS_HOME_NUMBER], [Type] ) 
	Values ( NEWID(), LTrim(Rtrim(@MRN)),LTrim(Rtrim(@CSN)),Replace(LTrim(Rtrim(@PATIENT_NAME)),'''',''),LTrim(Rtrim(@DOB)),LTrim(Rtrim(@ADMIT_DATE)),LTrim(Rtrim(@CLASS)),
	LTrim(Rtrim(@MEDICAIDE_NUMBER)),LTrim(Rtrim(@VISIT_REASON)),Replace(LTrim(Rtrim(@PCP)),'''',''),LTrim(Rtrim(@DISCHARGE_DISPOSITION)),LTrim(Rtrim(@PATIENTS_HOME_NUMBER)),
	LTrim(Rtrim(@Type)))

END