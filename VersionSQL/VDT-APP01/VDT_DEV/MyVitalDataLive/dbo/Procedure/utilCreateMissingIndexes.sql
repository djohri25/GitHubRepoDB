/****** Object:  Procedure [dbo].[utilCreateMissingIndexes]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE
utilCreateMissingIndexes
(
-- Set to 1 to create indexes; or, 0 to list missing indexes
	@p_create_yn bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_IndexExists bit = 0;
	DECLARE @v_TableName nvarchar(255);
	DECLARE @v_IndexName nvarchar(255);

	DROP TABLE IF EXISTS #FinalIndexes;
	CREATE TABLE
	#FinalIndexes
	(
		TableName nvarchar(255),
		IndexName nvarchar(255)
	);
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalClaimsDetail', 'ix_claimnumber' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalClaimsDetail', 'IX_MVDID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalClaimsDetail', 'PK_FinalClaimsDetail_RecordID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalClaimsDetailCode', 'IX_ClaimNumber' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalClaimsDetailCode', 'IX_MVDID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalClaimsDetailCode', 'PK_FinalClaimsDetailCode_RecordID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalClaimsHeader', 'IX_BatchID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalClaimsHeader', 'IX_FinalClaimsHeader_ClaimNumber' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalClaimsHeader', 'IX_MVDID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalClaimsHeader', 'PK_FinalClaimsHeader_RecordID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalClaimsHeaderCode', 'IX_ClaimNumber' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalClaimsHeaderCode', 'IX_mvdid' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalClaimsHeaderCode', 'PK_FinalClaimsHeaderCode_RecordID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalEligibilityETL', 'IC_RecordID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalEligibilityETL', 'IX_MemberID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalEligibilityETL', 'IX_Memberkey' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalEligibilityETL', 'IX_MVDID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalEligibilityETL', 'PK_FinalEligibility' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalLab', 'IC_FinalLab_MVDID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalLab', 'IX_Mvdid' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalLab', 'MemberID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalLab', 'PK_FinallAB_RecordID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalMemberETL', 'IC_RecordID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalMemberETL', 'IX_healthFlag' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalMemberETL', 'IX_Memberid' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalMemberETL', 'IX_MVDID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalMemberETL', 'PK_FinalMember_RecordID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalProvider', 'ix_ProviderID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalProvider', 'PK_FinalProvider_RecordID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalRX', 'IC_RecordID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalRX', 'IX_ClaimNumber' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalRX', 'IX_Claimkey' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalRX', 'ix_currentbatchid' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalRX', 'IX_MVDID' );
	INSERT INTO #FinalIndexes( TableName, IndexName ) VALUES ( 'FinalRX', 'PK_FinalRX_RecordID' );

	DECLARE IndexCursor
	CURSOR FOR
	SELECT
	*
	FROM
	#FinalIndexes;

	OPEN IndexCursor;

	FETCH NEXT FROM IndexCursor INTO
		@v_TableName,
		@v_IndexName;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @v_IndexExists = 0;

		SELECT
		@v_IndexExists = 1
		FROM
		sys.tables t
		JOIN sys.indexes i
		ON i.object_id = t.object_id
		AND i.name = @v_IndexName
		WHERE
		t.name = @v_TableName;

		IF ( @v_IndexExists = 0 )
		BEGIN
-- FinalClaimsDetail
			IF ( @v_IndexName = 'ix_claimnumber' AND @v_TableName = 'FinalClaimsDetail' )
			BEGIN
				CREATE NONCLUSTERED INDEX [ix_claimnumber] ON [dbo].[FinalClaimsDetail]
				(
					[ClaimNumber] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_MVDID' AND @v_TableName = 'FinalClaimsDetail' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_MVDID] ON [dbo].[FinalClaimsDetail]
				(
					[MVDID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'PK_FinalClaimsDetail_RecordID' AND @v_TableName = 'FinalClaimsDetail' )
			BEGIN
				ALTER TABLE [dbo].[FinalClaimsDetail] ADD  CONSTRAINT [PK_FinalClaimsDetail_RecordID] PRIMARY KEY CLUSTERED 
				(
					[RecordID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

-- FinalClaimsDetailCode
			IF ( @v_IndexName = 'IX_ClaimNumber' AND @v_TableName = 'FinalClaimsDetailCode' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_ClaimNumber] ON [dbo].[FinalClaimsDetailCode]
				(
					[ClaimNumber] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_MVDID' AND @v_TableName = 'FinalClaimsDetailCode' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_MVDID] ON [dbo].[FinalClaimsDetailCode]
				(
					[MVDID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'PK_FinalClaimsDetailCode_RecordID' AND @v_TableName = 'FinalClaimsDetailCode' )
			BEGIN
				ALTER TABLE [dbo].[FinalClaimsDetailCode] ADD  CONSTRAINT [PK_FinalClaimsDetailCode_RecordID] PRIMARY KEY CLUSTERED 
				(
					[RecordID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

-- FinalClaimsHeader
			IF ( @v_IndexName = 'IX_BatchID' AND @v_TableName = 'FinalClaimsHeader' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_BatchID] ON [dbo].[FinalClaimsHeader]
				(
					[CurrentBatchID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_FinalClaimsHeader_ClaimNumber' AND @v_TableName = 'FinalClaimsHeader' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_FinalClaimsHeader_ClaimNumber] ON [dbo].[FinalClaimsHeader]
				(
					[ClaimNumber] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_MVDID' AND @v_TableName = 'FinalClaimsHeader' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_MVDID] ON [dbo].[FinalClaimsHeader]
				(
					[MVDID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'PK_FinalClaimsHeader_RecordID' AND @v_TableName = 'FinalClaimsHeader' )
			BEGIN
				ALTER TABLE [dbo].[FinalClaimsHeader] ADD  CONSTRAINT [PK_FinalClaimsHeader_RecordID] PRIMARY KEY CLUSTERED 
				(
					[RecordID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

-- FinalClaimsHeaderCode
			IF ( @v_IndexName = 'IX_ClaimNumber' AND @v_TableName = 'FinalClaimsHeaderCode' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_ClaimNumber] ON [dbo].[FinalClaimsHeaderCode]
				(
					[ClaimNumber] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_mvdid' AND @v_TableName = 'FinalClaimsHeaderCode' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_mvdid] ON [dbo].[FinalClaimsHeaderCode]
				(
					[MVDID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'PK_FinalClaimsHeaderCode_RecordID' AND @v_TableName = 'FinalClaimsHeaderCode' )
			BEGIN
				ALTER TABLE [dbo].[FinalClaimsHeaderCode] ADD  CONSTRAINT [PK_FinalClaimsHeaderCode_RecordID] PRIMARY KEY CLUSTERED 
				(
					[RecordID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

-- FinalEligibilityETL
			IF ( @v_IndexName = 'IC_RecordID' AND @v_TableName = 'FinalEligibilityETL' )
			BEGIN
				CREATE CLUSTERED INDEX [IC_RecordID] ON [dbo].[FinalEligibilityETL]
				(
					[RecordID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_MemberID' AND @v_TableName = 'FinalEligibilityETL' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_MemberID] ON [dbo].[FinalEligibilityETL]
				(
					[MemberID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_Memberkey' AND @v_TableName = 'FinalEligibilityETL' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_Memberkey] ON [dbo].[FinalEligibilityETL]
				(
					[MemberID] ASC,
					[MemberKey] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_MVDID' AND @v_TableName = 'FinalEligibilityETL' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_MVDID] ON [dbo].[FinalEligibilityETL]
				(
					[MVDID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'PK_FinalEligibility' AND @v_TableName = 'FinalEligibilityETL' )
			BEGIN
				ALTER TABLE [dbo].[FinalEligibilityETL] ADD  CONSTRAINT [PK_FinalEligibility] PRIMARY KEY NONCLUSTERED 
				(
					[RecordID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

-- FinalLab
			IF ( @v_IndexName = 'IC_FinalLab_MVDID' AND @v_TableName = 'FinalLab' )
			BEGIN
				CREATE CLUSTERED INDEX [IC_FinalLab_MVDID] ON [dbo].[FinalLab]
				(
					[MVDID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_Mvdid' AND @v_TableName = 'FinalLab' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_Mvdid] ON [dbo].[FinalLab]
				(
					[MVDID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'MemberID' AND @v_TableName = 'FinalLab' )
			BEGIN
				CREATE NONCLUSTERED INDEX [MemberID] ON [dbo].[FinalLab]
				(
					[MemberID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'PK_FinallAB_RecordID' AND @v_TableName = 'FinalLab' )
			BEGIN
				ALTER TABLE [dbo].[FinalLab] ADD  CONSTRAINT [PK_FinallAB_RecordID] PRIMARY KEY NONCLUSTERED 
				(
					[RecordID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

-- FinalMemberETL
			IF ( @v_IndexName = 'IC_RecordID' AND @v_TableName = 'FinalMemberETL' )
			BEGIN
				CREATE CLUSTERED INDEX [IC_RecordID] ON [dbo].[FinalMemberETL]
				(
					[RecordID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_healthFlag' AND @v_TableName = 'FinalMemberETL' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_healthFlag] ON [dbo].[FinalMemberETL]
				(
					[HealthPlanEmployeeFlag] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_Memberid' AND @v_TableName = 'FinalMemberETL' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_Memberid] ON [dbo].[FinalMemberETL]
				(
					[MemberID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_MVDID' AND @v_TableName = 'FinalMemberETL' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_MVDID] ON [dbo].[FinalMemberETL]
				(
					[MVDID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'PK_FinalMember_RecordID' AND @v_TableName = 'FinalMemberETL' )
			BEGIN
				ALTER TABLE [dbo].[FinalMemberETL] ADD  CONSTRAINT [PK_FinalMember_RecordID] PRIMARY KEY NONCLUSTERED 
				(
					[RecordID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

-- FinalProvider
			IF ( @v_IndexName = 'ix_ProviderID' AND @v_TableName = 'FinalProvider' )
			BEGIN
				CREATE NONCLUSTERED INDEX [ix_ProviderID] ON [dbo].[FinalProvider]
				(
					[ProviderID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'PK_FinalProvider_RecordID' AND @v_TableName = 'FinalProvider' )
			BEGIN
				ALTER TABLE [dbo].[FinalProvider] ADD  CONSTRAINT [PK_FinalProvider_RecordID] PRIMARY KEY CLUSTERED 
				(
					[RecordID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

-- FinalRX
			IF ( @v_IndexName = 'IC_RecordID' AND @v_TableName = 'FinalRX' )
			BEGIN
				CREATE CLUSTERED INDEX [IC_RecordID] ON [dbo].[FinalRX]
				(
					[RecordID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_Claimkey' AND @v_TableName = 'FinalRX' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_Claimkey] ON [dbo].[FinalRX]
				(
					[claimkey] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_ClaimNumber' AND @v_TableName = 'FinalRX' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_ClaimNumber] ON [dbo].[FinalRX]
				(
					[ClaimNumber] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'ix_currentbatchid' AND @v_TableName = 'FinalRX' )
			BEGIN
				CREATE NONCLUSTERED INDEX [ix_currentbatchid] ON [dbo].[FinalRX]
				(
					[CurrentBatchID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'IX_MVDID' AND @v_TableName = 'FinalRX' )
			BEGIN
				CREATE NONCLUSTERED INDEX [IX_MVDID] ON [dbo].[FinalRX]
				(
					[MVDID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

			IF ( @v_IndexName = 'PK_FinalRX_RecordID' AND @v_TableName = 'FinalRX' )
			BEGIN
				ALTER TABLE [dbo].[FinalRX] ADD  CONSTRAINT [PK_FinalRX_RecordID] PRIMARY KEY NONCLUSTERED 
				(
					[RecordID] ASC
				)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
			END;

		END;

		FETCH NEXT FROM IndexCursor INTO
			@v_TableName,
			@v_IndexName;
	END;

END;