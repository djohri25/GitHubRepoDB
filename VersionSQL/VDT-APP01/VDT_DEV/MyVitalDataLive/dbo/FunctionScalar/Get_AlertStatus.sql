/****** Object:  Function [dbo].[Get_AlertStatus]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[Get_AlertStatus] 
(
	@DischargeRecordType varchar(50),
	@CustID varchar(20),
	@AlertDateTime datetime,		-- UTC time
	@RecordSourceName varchar(50),
	@FacilityID int
)
RETURNS int
AS
BEGIN
	DECLARE @AlertStatusID int,
		@CustName varchar(50),
		@dayOfWeek int,
		@tempTime varchar(10)

	set @AlertStatusID = 0 

	/*
		1 - Sunday
		2 - Monday
		3 - Tuesday
		4 - Wednesday
		5 - Thursday
		6 - Friday
		7 - Saturday
	*/
	
	select @CustName = Name 
	from HpCustomer
	where cust_ID = @custID
	
	if( @CustName = 'Parkland')
	begin
		set @AlertStatusID = 0 
	end
	else if ( @CustName like 'Amerigroup%' AND @RecordSourceName = 'Discharge Data' 
		AND exists (select ID from mainEMSHospital where id= @FacilityID and name like 'Cook%'))
	begin
		-- Cook Children Medical Center provides discharge records with dates but no time,
		-- so we don't want to classify them as after hours etc
		set @AlertStatusID = 0 
	end	
	else if ( @CustName like 'Amerigroup%')
	begin
		
		if(@DischargeRecordType is not null AND @DischargeRecordType = 'DAL EMERGENCY')
		begin
			select @AlertStatusID = ID from LookupHPAlertStatus where Name = 'Outreach not attempted'
		end
		else
		begin
			declare @AlertCentralTime datetime 
			set @AlertCentralTime = dbo.ConvertUTCtoCT(@AlertDateTime)
			select  @tempTime = SUBSTRING(convert(varchar,@AlertCentralTime,108),1,2) 
				+ SUBSTRING(convert(varchar,@AlertCentralTime,108),4,2)				
			
			set @dayOfWeek = DATEPART(weekday,@AlertCentralTime)
				
			if((@dayOfWeek between 2 and 6) and (@tempTime between 600 and 1900))
			begin
				set @AlertStatusID = 0     			
			end
			else
			begin
				select @AlertStatusID = ID from LookupHPAlertStatus where Name like '%After Hours'
			end
		end				
	end
	else
	begin
		if(@DischargeRecordType is not null AND @DischargeRecordType = 'DAL EMERGENCY')
		begin
			select @AlertStatusID = ID from LookupHPAlertStatus where Name = 'Outreach not attempted'
		end
		else
		begin
			set @AlertStatusID = 0     
		end
	end
	
	RETURN @AlertStatusID

END