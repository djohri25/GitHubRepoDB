/****** Object:  UserDefinedTableType [dbo].[udtMessageLink]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TYPE [dbo].[udtMessageLink] AS TABLE(
	[Title] [nvarchar](250) NULL,
	[Url] [nvarchar](max) NULL
)