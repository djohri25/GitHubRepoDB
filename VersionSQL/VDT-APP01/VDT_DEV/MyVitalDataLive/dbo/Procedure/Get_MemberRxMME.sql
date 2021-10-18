/****** Object:  Procedure [dbo].[Get_MemberRxMME]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_MemberRxMME]
@MedRecs [dbo].[MedRecExt] READONLY
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
	DECLARE @DBName varchar(50) -- = 'FirstDataBankDB'
	
	SET NOCOUNT ON;
	DECLARE @SQL_SCRIPT VARCHAR(MAX)
	DECLARE @R FLOAT = 0
	
	BEGIN TRY
		SELECT @R = sum(Rx_MME) from 
		( 
			select N.NDC, N.LN, O.MME_FACTOR, O.MME_PER_DOSAGE_UNIT, Quantity, DaysSupply, (Quantity * (O.MME_PER_DOSAGE_UNIT / DaysSupply)) as Rx_MME
			from (
				select NDC, 
				case when LEN(RTRIM(IsNull(Quantity,''))) < 1 then CAST(0 as FLOAT) else CAST(Quantity as FLOAT) end as Quantity, 
				case when LEN(RTRIM(IsNull(DaysSupply,''))) < 1 then case when LEN(RTRIM(IsNull(Quantity,''))) < 1 then CAST(0 as FLOAT) else CAST(Quantity as FLOAT) end else CAST(DaysSupply as FLOAT) end as DaysSupply 
				from @MedRecs
			) Rx 
			join [FirstDataBankDB].[dbo].[RNDC14_NDC_MSTR] N on N.NDC = Rx.NDC
			join [FirstDataBankDB].[dbo].[RORCFF0_OPIOID_CF_MME_FACTOR] O on O.[GCN_SEQNO] = N.[GCN_SEQNO]
			join [FirstDataBankDB].[dbo].[RORMSTR0_OPIOID_MED_MASTER] OM on OM.GCN_SEQNO = O.GCN_SEQNO
			where IsNull(O.MME_FACTOR,0) > 0 
			and IsNull(OM.MME_FACTOR_AVAILABLE_IND,0) = 1
		) a
	END TRY
	BEGIN CATCH
	END CATCH
	select @R as MemberRate,A.* from [FirstDataBankDB].[dbo].[RORALRT0_DAILY_MME_ALERTING] A 
	where @R between A.TOTAL_LOW_DAILY_MME and A.TOTAL_HIGH_DAILY_MME
END