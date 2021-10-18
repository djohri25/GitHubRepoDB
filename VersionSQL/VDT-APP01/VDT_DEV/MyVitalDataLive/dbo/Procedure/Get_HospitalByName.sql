/****** Object:  Procedure [dbo].[Get_HospitalByName]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 07/28/2008
-- Description:	Returns hospital by name
-- =============================================
CREATE PROCEDURE [dbo].[Get_HospitalByName]
	@Name varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		declare @adminEmails varchar(2000), -- List of emails of all administrators
			@supportDB varchar(20),
			@query varchar(2000)

		-- Retrieve the list of emails from the list of administrators for the hospital
		-- because they should be notified when new EMS request is submitted
		-- if no administrators set for the hospital use contact person's email
		set @supportDB = dbo.Get_SupportDBName()

		declare	@tempEmails table (Email varchar(50))

		set @adminEmails = ''

		set @query =
			'select m.Email from mainEmsHospital h
			inner join dbo.Link_SupUserHospital s on h.id = s.HospitalId
			inner join ' + @supportDB + '.dbo.aspnet_Membership m on s.supportToolUserId = m.userid
			where replace(h.Name,'''''''','''') = ''' + replace(@Name,'''','') + ''''

		insert into @tempEmails(Email)
		EXEC (@query)

		select @adminEmails = @adminEmails + Email + ','
		from @tempEmails

		if(len(@adminEmails) > 0)
		begin
			-- remove trailing comma
			set @adminEmails = substring(@adminEmails,0,len(@adminEmails) )
		end

		SELECT ID
		  ,Name
		  ,Address
		  ,City
		  ,State
		  ,Zip
		  ,ContactName
		  ,case isnull(@adminEmails,'')
			when '' then ContactEmail
			else
				@adminEmails
			end as 'ContactEmail'
		  ,Substring(ContactPhone,1,3) As ContactPhoneArea
		  ,Substring(ContactPhone,4,3) As ContactPhonePrefix
		  ,Substring(ContactPhone,7,4) As ContactPhoneSuffix
		  ,dbo.FormatPhone(ContactPhone) As ContactPhone
		  ,Website
		  ,IP
		  ,ApprovedDate
		  ,Active
		  ,CredentialsRequired
		  ,AutoApprove
		  ,RestrictedEmailDomains
		  ,RequiresDetailConfirmation
	  FROM MainEMSHospital
	  where Name = @Name
END