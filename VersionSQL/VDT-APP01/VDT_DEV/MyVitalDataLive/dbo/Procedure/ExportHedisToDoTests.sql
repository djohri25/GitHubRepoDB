/****** Object:  Procedure [dbo].[ExportHedisToDoTests]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 4/13/2012
-- Description:	Creates text file with recently created alerts. File is comma separated
-- =============================================
CREATE PROCEDURE [dbo].[ExportHedisToDoTests]
AS
BEGIN
	SET NOCOUNT ON;

	declare @lastExport datetime, @amerigroupCustID int, @parklandCustID int
	declare @result varchar(max), @fileName varchar(50),@curDate varchar(10),
		@header varchar(1000), @recordCount int
		
	declare @temp table (
		MemberID varchar(50),
		HedisCode varchar(50)
	)

	select @curDate = CONVERT(varchar(10), getdate(), 101)
	
	select @header = 'MEMBER_ID,HEDIS_CODE'
		+ CHAR(10)

	select @result = @header, @fileName = ''
	
	set @fileName = 'MemberHedis_' 
		+ left(@curDate,2)
		+ substring(@curDate,4,2)
		+ right(@curDate,4)
		+ '.csv'
	
	select @amerigroupCustID = Cust_ID
	from HPCustomer
	where Name = 'Amerigroup' and ParentID is null


	select @parklandCustID = Cust_ID
	from HPCustomer
	where Name = 'Parkland' and ParentID is null
	
	insert into @temp(MemberID,HedisCode)
	select m.MemberID, h.Abbreviation
	from [Final_HEDIS_Member] m
		inner join LookupHedis h on m.TestID = h.ID
		inner join Link_MVDID_CustID li on m.MemberID = li.InsMemberId
	--where li.Cust_ID in(@amerigroupCustID, @parklandCustID)

	select @result = @result + MemberID + ',' +HedisCode + CHAR(10)
	from @temp
	
	select @recordCount = COUNT(MemberID)
	from @temp
	
	--select @result
	--select @fileName
	
	EXEC WriteStringToFile
		@String = @result,
		@Path = '\\vitaldataweb01\c$\sftproot\MiDoctors',
		@Filename = @fileName

--		@Path = 'Z:\Outbound',
		
	--insert into ExportNewAlertsLog(ExportDate,Filename,RecordCount,Note,Success)
	--values(GETUTCDATE(),@fileName,@recordCount,'',1)
END