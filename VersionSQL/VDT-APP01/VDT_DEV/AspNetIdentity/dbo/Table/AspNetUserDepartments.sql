/****** Object:  Table [dbo].[AspNetUserDepartments]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AspNetUserDepartments](
	[UserId] [nvarchar](128) NOT NULL,
	[DepartmentId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_AspNetUserDepartments_1] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[DepartmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[AspNetUserDepartments]  WITH CHECK ADD FOREIGN KEY([DepartmentId])
REFERENCES [dbo].[AspNetDepartments] ([Id])
ALTER TABLE [dbo].[AspNetUserDepartments]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserDepartments_AspNetUsers] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers_20210201] ([Id])
ALTER TABLE [dbo].[AspNetUserDepartments] CHECK CONSTRAINT [FK_AspNetUserDepartments_AspNetUsers]