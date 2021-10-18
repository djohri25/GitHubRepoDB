/****** Object:  Table [dbo].[VitalData_MaternityEligibleFull]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[VitalData_MaternityEligibleFull](
	[MemberID] [nvarchar](50) NOT NULL,
	[MaternityElig] [nvarchar](50) NOT NULL,
	[LoadDate] [date] NULL,
	[SourceFileName] [nvarchar](100) NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_VitalData_MaternityEligibleFull_MemberID] ON [dbo].[VitalData_MaternityEligibleFull]
(
	[MemberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[VitalData_MaternityEligibleFull] ADD  DEFAULT (getdate()) FOR [LoadDate]