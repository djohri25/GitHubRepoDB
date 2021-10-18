/****** Object:  Procedure [dbo].[Import_Driscoll_Eligibility_AddInfo_Single]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		ppetluri
-- Create date: 11/01/2016
-- Description:	Import single Demographic record
-- =============================================
CREATE PROCEDURE [dbo].[Import_Driscoll_Eligibility_AddInfo_Single]
	@recordId int,
	@InsMemberID varchar(30),
	@Plan_stratid [varchar](50),
	@dual [varchar](50),
	@MedicareID [varchar](30),
	@medicare_effdt [varchar](50),
	@medicare_termdt [varchar](50),
	@language [varchar](50),
	@migrant [varchar](50),
	@benefit_code [varchar](50),
	@waiver_toa [varchar](50),
	@Cust_ID int,
	@LOB	VARCHAR(10),
	@UpdateResult int output
AS
BEGIN
	SET NOCOUNT ON;
	
	declare 	@MVDId varchar(15)
	Declare		@RowCount	INT

	SET @UpdateResult = 0 

	set @InsMemberID = dbo.RemoveLeadChars(@InsMemberID,'0')

	IF OBJECT_ID (N'tempdb.dbo.#Temp_Stage', N'U') IS NOT NULL 
    DROP TABLE #Temp_Stage;
	Create Table #Temp_Stage 
	(
		[InsMemberID] varchar(30),
		[ICENUMBER]		varchar(15) NULL,
		[Cust_ID] [int] NULL,
		[LOBId]	int ,
		[Plan_stratid] [varchar](50) NULL,
		[dual] [varchar](50) NULL,
		[MedicareID] [varchar](30) NULL,
		[medicare_effdt] [varchar](50) NULL,
		[medicare_termdt] [varchar](50) NULL,
		[language] [varchar](50) NULL,
		[migrant] [varchar](50) NULL,
		[benefit_code] [varchar](50) NULL,
		[waiver_toa] [varchar](50) NULL
	)
	BEGIN TRY
		BEGIN TRAN
		
			UPDATE P 
			SET P.[Language] = @Language
			FROM MainPersonalDetails P JOIN Link_MemberId_MVD_Ins L On L.MVDID = P.ICENUMBER 
			WHERE L.Cust_ID = @Cust_ID and L.InsMemberId = @InsMemberID

			SET @RowCOunt = @@RowCount
			IF @RowCOunt = 0 
			BEGIN
				SET @UpdateResult = -1
			END

			INSERT INTO #Temp_Stage 
			(	InsMemberID,
				[Cust_ID],
				[LOBId],
				[Plan_stratid],
				[dual],
				[MedicareID],
				[medicare_effdt],
				[medicare_termdt],
				[language],
				[migrant],
				[benefit_code],
				[waiver_toa]
			)
			Select  @InsMemberID,
					@Cust_ID,
					(Select CodeID from Lookup_Generic_Code Where Cust_id = @Cust_ID and Label = @LOB) as LOBId,
					@Plan_stratid ,
					@dual,
					@MedicareID,
					@medicare_effdt,
					@medicare_termdt,
					@language,
					@migrant,
					@benefit_code,
					@waiver_toa

			UPDATE T 
			SET [ICENUMBER] = L.MVDId
			FROM #Temp_Stage T JOIN Link_MemberId_MVD_Ins L On L.InsMemberID = T.InsMemberID and L.Cust_ID = T.Cust_ID 
			
			MERGE Driscoll_EligibilityAdditionalInfo AS Target
			USING (SELECT InsMemberID,ICENUMBER,[Cust_ID],[LOBId],[Plan_stratid],[dual],[MedicareID],[medicare_effdt],[medicare_termdt],[language],[migrant],[benefit_code],[waiver_toa] FROM #Temp_Stage) AS Source
			ON (Target.ICENUMBER = Source.ICENUMBER AND Target.Cust_ID = Source.Cust_ID)
			WHEN MATCHED THEN
				UPDATE SET Target.LOBId = Source.LOBId,
						   Target.Plan_stratid = Source.Plan_stratid,
						   Target.dual = Source.dual,
						   Target.MedicareID = Source.MedicareID,
						   Target.medicare_effdt = Source.medicare_effdt,
						   Target.medicare_termdt = Source.medicare_termdt,
						   Target.migrant = Source.migrant,
						   Target.benefit_code = Source.benefit_code,
						   Target.waiver_toa = Source.waiver_toa,
						   Target.Updated = GETDATE()
			WHEN NOT MATCHED BY TARGET THEN
				INSERT ([ICENUMBER],[Cust_id],[LOBId],[Plan_stratid],[dual],[MedicareID],[medicare_effdt],[medicare_termdt],[migrant],[benefit_code],[waiver_toa])
				VALUES (Source.ICENUMBER,Source.[Cust_id],Source.[LOBId],Source.[Plan_stratid],Source.[dual],Source.[MedicareID],Source.[medicare_effdt],Source.[medicare_termdt],Source.[migrant],Source.[benefit_code],Source.[waiver_toa]);
			--OUTPUT $action, Inserted.*; 
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		DECLARE @addInfo nvarchar(MAX)
		SELECT	@UpdateResult = -1,
				@addInfo = 
					'RecordId=' + CAST(@RecordId AS VARCHAR(16)) + ', InsMemberID=' + ISNULL(@InsMemberID, 'NULL') + ', MedicareID=' + ISNULL(@MedicareID, 'NULL')
					+ ', Cust_id=' + ISNULL(@Cust_ID, 'NULL') + ', LOB=' + ISNULL(@LOB, 'NULL')

		EXEC ImportCatchError @addInfo
	END CATCH
	
END