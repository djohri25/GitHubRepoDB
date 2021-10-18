/****** Object:  Procedure [dbo].[Merge_Place]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12/28/2010
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Merge_Place]
	@MVDID_1 varchar(20),	-- primary MVD record, updated based on record #2
	@MVDID_2 varchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	if not exists(select top 1 RecordNumber from MainPlaces where ICENUMBER = @MVDID_1)
	begin
		insert into MainPlaces(
			ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone
			,FaxPhone,WebSite,PlacesTypeID,RoomLoc,Direction,Note
			,CreationDate,ModifyDate)
		select @MVDID_1,Name,Address1,Address2,City,State,Postal,Phone
			,FaxPhone,WebSite,PlacesTypeID,RoomLoc,Direction,Note
			,CreationDate,ModifyDate
        from MainPlaces
        where ICENUMBER = @MVDID_2
	end
	else
	begin
		declare @recordNumber2 int, @Name2 varchar(100),
			@recordNumber1 int, @modifyDateRec1 datetime, @modifyDateRec2 datetime 
	
		declare @tempPlaces1 table (
			RecordNumber int,ICENUMBER varchar(15),Name varchar(50),Address1 varchar(50),
			Address2 varchar(50),City varchar(50),State varchar(2),Postal varchar(5),
			Phone varchar(10),FaxPhone varchar(10),WebSite varchar(200),PlacesTypeID int,
			RoomLoc varchar(50),Direction varchar(150),Note varchar(250),
			CreationDate datetime,ModifyDate datetime,
			isProcessed bit default(0)
		)

		declare @tempPlaces2 table (
			RecordNumber int,ICENUMBER varchar(15),Name varchar(50),Address1 varchar(50),
			Address2 varchar(50),City varchar(50),State varchar(2),Postal varchar(5),
			Phone varchar(10),FaxPhone varchar(10),WebSite varchar(200),PlacesTypeID int,
			RoomLoc varchar(50),Direction varchar(150),Note varchar(250),
			CreationDate datetime,ModifyDate datetime,
			isProcessed bit default(0)
		)
	
		insert into @tempPlaces1(
			RecordNumber,ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone
			,FaxPhone,WebSite,PlacesTypeID,RoomLoc,Direction,Note
			,CreationDate,ModifyDate)
		select RecordNumber,ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone
			,FaxPhone,WebSite,PlacesTypeID,RoomLoc,Direction,Note
			,CreationDate,ModifyDate
        from MainPlaces
        where ICENUMBER = @MVDID_1

		insert into @tempPlaces2(
			RecordNumber,ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone
			,FaxPhone,WebSite,PlacesTypeID,RoomLoc,Direction,Note
			,CreationDate,ModifyDate)
		select RecordNumber,ICENUMBER,Name,Address1,Address2,City,State,Postal,Phone
			,FaxPhone,WebSite,PlacesTypeID,RoomLoc,Direction,Note
			,CreationDate,ModifyDate
        from MainPlaces
        where ICENUMBER = @MVDID_2
               
        while exists(select top 1 recordnumber from @tempPlaces2 where isProcessed = 0)
		begin		
		
			select top 1 
				@recordNumber2 = RecordNumber,
				@Name2 = Name,
				@modifyDateRec2 = ModifyDate
			from @tempPlaces2
			where isProcessed = 0	
	
			select top 1 @recordnumber1 = RecordNumber,
				@modifyDateRec1 = ModifyDate
			from @tempPlaces1
			where Name = @Name2
				
			if ISNULL(@recordNumber1,'') = '' OR (ISNULL(@recordNumber1,'') <> '' AND @modifyDateRec2 > @modifyDateRec1)
			begin
				delete from MainPlaces	
				where RecordNumber = @recordNumber1
			
				insert into MainPlaces(
					ICENUMBER
					,Name,Address1,Address2,City,State,Postal,Phone
					,FaxPhone,WebSite,PlacesTypeID,RoomLoc,Direction,Note
					,CreationDate,ModifyDate)
				select @MVDID_1,
					Name,Address1,Address2,City,State,Postal,Phone
					,FaxPhone,WebSite,PlacesTypeID,RoomLoc,Direction,Note
					,CreationDate,ModifyDate
				from @tempPlaces2
				where RecordNumber = @recordNumber2
			end
			
			select @recordNumber1 = null,
				@modifyDateRec1 = null
		
			update @tempPlaces2 set isProcessed = 1
			where RecordNumber = @recordNumber2			
		end
	end
END