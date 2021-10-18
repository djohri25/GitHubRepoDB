/****** Object:  Procedure [dbo].[Get_Attachment]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE Procedure [dbo].[Get_Attachment]
	@IceNumber varchar(15)
As
	SET NOCOUNT ON

--	declare @maxAtt float
--
--	 Get max size of the storage space for the member
--	select @maxAtt = (SELECT top 1 (MaxAttachment/1024.0) FROM MainUserName mun 
--			JOIN MainICENUMBERGroups ming ON mun.ICEGROUP = ming.ICEGROUP 
--			WHERE ICENUMBER = @IceNumber)
--
--	create table #tempResult (icenumber varchar(50), MaxAttachment float)
--
--	insert into #tempResult (icenumber, MaxAttachment)
--	values (@IceNumber, @maxAtt)
--
--	select b.RecordNumber, b.FileName, b.Description, (FileSize/1024.0) AS FileSize,
--		(SELECT isnull(SUM(FileSize),0) FROM MainAttachments WHERE ICENUMBER = @IceNumber) AS FileByteTotal,
--		(SELECT isnull(SUM(FileSize)/1024.0,0) FROM MainAttachments WHERE ICENUMBER = @IceNumber) As FileTotal,
--		a.MaxAttachment,
--		BinaryName
--	from #tempResult a
--		left join MainAttachments b on a.ICENUMBER=b.ICENUMBER
--	where a.ICENUMBER = @IceNumber
--
--	drop table #tempResult

	SELECT RecordNumber, [FileName], Description, (FileSize/1024.0) AS FileSize, 
	(SELECT SUM(FileSize) FROM MainAttachments WHERE ICENUMBER = @IceNumber) AS FileByteTotal,
	(SELECT SUM(FileSize)/1024.0 FROM MainAttachments WHERE ICENUMBER = @IceNumber) As FileTotal, 
	(SELECT MaxAttachment/1024.0 FROM MainUserName mun JOIN MainICENUMBERGroups ming ON mun.ICEGROUP = ming.ICEGROUP WHERE ICENUMBER = @IceNumber) as MaxAttachment, 
	BinaryName FROM MainAttachments	WHERE ICENUMBER = @IceNumber