/****** Object:  Table [dbo].[AspNetUserSupervisors]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AspNetUserSupervisors](
	[UserId] [nvarchar](128) NOT NULL,
	[SupervisorId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_AspNetUserSupervisors] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[SupervisorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[AspNetUserSupervisors]  WITH CHECK ADD FOREIGN KEY([SupervisorId])
REFERENCES [dbo].[AspNetSupervisors] ([Id])
ALTER TABLE [dbo].[AspNetUserSupervisors]  WITH CHECK ADD  CONSTRAINT [FK_Table_AspNetUserSupervisor_AspNet_Supervisors] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers_20210201] ([Id])
ALTER TABLE [dbo].[AspNetUserSupervisors] CHECK CONSTRAINT [FK_Table_AspNetUserSupervisor_AspNet_Supervisors]