/****** Object:  Procedure [dbo].[Get_HospitalList]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 07/24/2008
-- Description:	Returns the list of hospitals matching 
--	the criteria
--	@ActiveFilter might have the following values: ALL, ACTIVE, INACTIVE
-- =============================================
CREATE PROCEDURE [dbo].[Get_HospitalList]
	@ActiveFilter varchar(15),
	@Category varchar(50) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @query varchar(1000),
		@type varchar(50),
		@Active bit

	if(ISNULL(@Category,'') = '')
	begin
		set @type = 'ER'
	end
	else
	begin
		set @type = @Category
	end
		
	if(isnull(@ActiveFilter,'') = 'ACTIVE')
	begin
		set @Active = 1
	end
	else
	begin
		set @Active = 0
	end
	
	if( isnull(@ActiveFilter,'') <> '' and @ActiveFilter != 'ALL')
	begin
		SELECT ID
		  ,Name,Address,City,State,Zip,ContactName,ContactEmail
		  ,Substring(ContactPhone,1,3) As ContactPhoneArea
		  ,Substring(ContactPhone,4,3) As ContactPhonePrefix
		  ,Substring(ContactPhone,7,4) As ContactPhoneSuffix
		  ,dbo.FormatPhone(ContactPhone) As ContactPhone
		  ,Website,IP,ApprovedDate,Active,CredentialsRequired,AutoApprove
		  ,Modified,Created,MinorsAge,RestrictedEmailDomains
	  FROM MainEMSHospital 
	  where Active = @Active and category = @type
	  order by name
	end
	else
	begin
		-- ALL
		SELECT ID
		  ,Name,Address,City,State,Zip,ContactName,ContactEmail
		  ,Substring(ContactPhone,1,3) As ContactPhoneArea
		  ,Substring(ContactPhone,4,3) As ContactPhonePrefix
		  ,Substring(ContactPhone,7,4) As ContactPhoneSuffix
		  ,dbo.FormatPhone(ContactPhone) As ContactPhone
		  ,Website,IP,ApprovedDate,Active,CredentialsRequired,AutoApprove
		  ,Modified,Created,MinorsAge,RestrictedEmailDomains
	  FROM MainEMSHospital
	  where category = @type 
	  order by name	
	end	  
END