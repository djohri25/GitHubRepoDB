/****** Object:  Table [dbo].[VitalData_Maternity_DentalXtra]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[VitalData_Maternity_DentalXtra](
	[Member_ID] [varchar](50) NULL,
	[DentalXtraInd] [varchar](50) NULL
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_VitalData_Maternity_DentalXtra_Member_ID] ON [dbo].[VitalData_Maternity_DentalXtra]
(
	[Member_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]