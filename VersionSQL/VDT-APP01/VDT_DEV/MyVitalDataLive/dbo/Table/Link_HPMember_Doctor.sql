/****** Object:  Table [dbo].[Link_HPMember_Doctor]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Link_HPMember_Doctor](
	[MVDID] [varchar](15) NOT NULL,
	[Doctor_Id] [nvarchar](50) NOT NULL,
	[DoctorFirstName] [varchar](50) NULL,
	[DoctorLastName] [varchar](50) NULL,
	[Created] [datetime] NULL,
 CONSTRAINT [PK_Link_HPMember_Doctor_1] PRIMARY KEY CLUSTERED 
(
	[MVDID] ASC,
	[Doctor_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[Link_HPMember_Doctor] ADD  CONSTRAINT [DF_Link_HPMember_Doctor_Created]  DEFAULT (getutcdate()) FOR [Created]
ALTER TABLE [dbo].[Link_HPMember_Doctor]  WITH CHECK ADD  CONSTRAINT [FK_Link_HPMember_Doctor_Link_HPMember_Doctor] FOREIGN KEY([MVDID])
REFERENCES [dbo].[MainPersonalDetails] ([ICENUMBER])
ALTER TABLE [dbo].[Link_HPMember_Doctor] CHECK CONSTRAINT [FK_Link_HPMember_Doctor_Link_HPMember_Doctor]