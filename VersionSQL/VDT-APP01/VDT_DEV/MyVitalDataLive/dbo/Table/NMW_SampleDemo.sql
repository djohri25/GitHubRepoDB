/****** Object:  Table [dbo].[NMW_SampleDemo]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[NMW_SampleDemo](
	[Program] [varchar](100) NULL,
	[SourceFacility] [varchar](100) NULL,
	[DestinationFacility] [varchar](100) NULL,
	[Destinationtype] [varchar](20) NULL,
	[AdmitDate] [datetime] NULL,
	[DischargeDate] [datetime] NULL,
	[DischargeToLocation] [varchar](100) NULL,
	[DischargeDisposition] [varchar](100) NULL,
	[ProjectedLOS] [smallint] NULL,
	[ActualLOS] [smallint] NULL,
	[LOS_percent]  AS (CONVERT([decimal](6,2),([ActualLOS]*(100))/[ProjectedLOS])),
	[ED_Count] [int] NULL,
	[Last_MDSdate] [datetime] NULL,
	[Last_MDStype] [varchar](20) NULL,
	[MDS_RUG] [varchar](10) NULL,
	[Rule_Type] [varchar](100) NULL,
	[Last2MVDID] [varchar](2) NULL
) ON [PRIMARY]