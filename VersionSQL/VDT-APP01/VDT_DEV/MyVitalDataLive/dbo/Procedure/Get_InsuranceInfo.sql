/****** Object:  Procedure [dbo].[Get_InsuranceInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_InsuranceInfo] 
	@ICENUMBER varchar(15),
	@NoDups bit = 0,
	@Language BIT = 1
AS
BEGIN

	SET NOCOUNT ON

	IF @NoDups = 0
	BEGIN
		SELECT RecordNumber, ISNULL([Name], '') AS [Name], 
		    ISNULL(Address1, '') AS Address1, 
		    ISNULL(Address2, '') AS Address2, 
		    ISNULL(City, '') AS City, 
		    ISNULL(State, '') AS State, 
		    ISNULL(Postal, '') AS Postal, 
		    InsuranceTypeID, 'Insurance' AS MobileDescription,
				(	
				SELECT TOP 1 
					CASE @Language
						WHEN  1 
							THEN InsuranceTypeName 
						WHEN 0 
							THEN InsuranceTypeNameSpanish
					END  
				FROM LookupInsuranceTypeID
				WHERE (InsuranceTypeID = MainInsurance.InsuranceTypeID)) AS InsuranceName, 
			SUBSTRING(Phone, 1, 3) AS PhoneArea, 
			SUBSTRING(Phone, 4, 3) AS PhonePrefix, 
			SUBSTRING(Phone, 7, 4) AS PhoneSuffix, 
			SUBSTRING(FaxPhone, 1, 3) AS FaxArea, 
			SUBSTRING(FaxPhone, 4, 3) AS FaxPrefix, 
			SUBSTRING(FaxPhone, 7, 4) AS FaxSuffix, 
			dbo.FormatPhone(Phone) AS PhoneFull, 
			dbo.FormatPhone(FaxPhone) AS FaxPhoneFull, 
			ISNULL(PolicyHolderName, '') AS PolicyHolderName, 
			ISNULL(GroupNumber, '') AS GroupNumber, 
			ISNULL(PolicyNumber, '') AS PolicyNumber, 
			ISNULL(WebSite, '') AS Website, 
			ISNULL(Medicaid, '') AS Medicaid, 
			ISNULL(MedicareNumber, '')AS MedicareNumber, 
			ISNULL(ReadOnly, 0) AS ReadOnly
		FROM MainInsurance
		WHERE (ICENUMBER = @ICENUMBER)
	END
	ELSE
	BEGIN
		SELECT RecordNumber, ICENUMBER, [Name], 
		     Address1, Address2, City, State, Postal, Phone, 
		     FaxPhone, PolicyHolderName, GroupNumber, 
		     PolicyNumber, WebSite, InsuranceTypeID, 
		     CreationDate, ModifyDate, Medicaid, 
		     MedicareNumber, HVID, HVFlag, 
		     ReadOnly
		INTO #Insurance
		FROM MainInsurance
		WHERE ICENUMBER = @ICENUMBER
		
		DECLARE currentRow CURSOR FOR
			SELECT DISTINCT [Name]
			FROM MainInsurance
			WHERE (ICENUMBER = @ICENUMBER)
			ORDER BY [Name]

		OPEN currentRow
		
		IF @@CURSOR_ROWS > 0
		BEGIN
			DECLARE @RecordNumber INT, @Name VARCHAR(50), @count INT
			
			WHILE 1 = 1
			BEGIN
				FETCH NEXT FROM currentRow INTO @Name
				IF @@FETCH_STATUS <> 0
					BREAK
				SELECT @count = count(*)
				FROM #Insurance
				WHERE [Name] = @Name
				IF @count > 1
				BEGIN
					SELECT TOP (1) @RecordNumber = RecordNumber
					FROM #Insurance
					WHERE ([Name] = @Name)
					ORDER BY ModifyDate DESC
					
					DELETE #Insurance
					WHERE (RecordNumber <> @RecordNumber) AND 
					     ([Name] = @Name) 
				END
			END
		END
		
		CLOSE currentRow

		SELECT RecordNumber, ISNULL([Name], '') AS [Name], 
		    ISNULL(Address1, '') AS Address1, 
		    ISNULL(Address2, '') AS Address2, 
		    ISNULL(City, '') AS City, 
		    ISNULL(State, '') AS State, 
		    ISNULL(Postal, '') AS Postal, 
		    InsuranceTypeID, 'Insurance' AS MobileDescription,
				(
					SELECT TOP 1 
					CASE @Language
						WHEN  1 
							THEN InsuranceTypeName 
						WHEN 0 
							THEN InsuranceTypeNameSpanish
					END  
					FROM LookupInsuranceTypeID
					WHERE (InsuranceTypeID = #Insurance.InsuranceTypeID)) AS InsuranceName, 
			SUBSTRING(Phone, 1, 3) AS PhoneArea, 
			SUBSTRING(Phone, 4, 3) AS PhonePrefix, 
			SUBSTRING(Phone, 7, 4) AS PhoneSuffix, 
			SUBSTRING(FaxPhone, 1, 3) AS FaxArea, 
			SUBSTRING(FaxPhone, 4, 3) AS FaxPrefix, 
			SUBSTRING(FaxPhone, 7, 4) AS FaxSuffix, 
			dbo.FormatPhone(Phone) AS PhoneFull, 
			dbo.FormatPhone(FaxPhone) AS FaxPhoneFull, 
			ISNULL(PolicyHolderName, '') AS PolicyHolderName, 
			ISNULL(GroupNumber, '') AS GroupNumber, 
			ISNULL(PolicyNumber, '') AS PolicyNumber, 
			ISNULL(WebSite, '') AS Website, 
			ISNULL(Medicaid, '') AS Medicaid, 
			ISNULL(MedicareNumber, '')AS MedicareNumber, 
			ISNULL(ReadOnly, 0) AS ReadOnly
		FROM #Insurance

		DROP TABLE #Insurance
	END
END	