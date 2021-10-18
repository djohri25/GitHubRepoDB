/****** Object:  Procedure [dbo].[Get_HLUsersByCompany]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 02/14/2012
-- Description:	 Returns the list of HL users associated with the hospital
--		If @ is empty or '0' return the full list of agents
-- =============================================
create PROCEDURE [dbo].[Get_HLUsersByCompany]
	@Company varchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	declare @query varchar(2000), @DBName varchar(50), @companyID varchar(10)

	select @companyID = id 
	from MainEMSHospital 
	where name = @Company

	select @DBName = dbo.Get_SupportDBName()

	select @query = 	
	  '
	  SELECT b.UserName
			,b.UserId
			,Password
			,lower(Email) as Email
			,dbo.InitCap(FirstName) as FirstName
			,dbo.InitCap(LastName) as LastName
			,dbo.InitCap(LastName + '', '' +  FirstName) as FullName
			,HospitalID		
			,h.Name as HospitalName
			,a.Address
			,a.City
			,a.State
			,a.Zip
		    ,Substring(Phone,1,3) As PhoneArea
		    ,Substring(Phone,4,3) As PhonePrefix
		    ,Substring(Phone,7,4) As PhoneSuffix
		    ,dbo.FormatPhone(Phone) As Phone
			,a.Active
			,ContactBySMS
			,ContactByEmail
		FROM ' + @DBName + '.dbo.aspnet_Membership a
			inner join ' + @DBName + '.dbo.aspnet_Users b on a.UserId = b.UserId 
			inner join ' + @DBName + '.dbo.aspnet_UsersInRoles r on b.UserId = r.UserId
			inner join ' + @DBName + '.dbo.aspnet_Roles ro on r.roleID = ro.roleID
			inner join Link_SupUserHospital s on a.userid = s.supportToolUserid
			inner join dbo.MainEMSHospital h on s.hospitalID = h.ID
		where RoleName like ''' + 'HL_User%' + '''
			and h.category = ''' + 'HL' + '''
			and isnull(s.HospitalID,''' + ''') = 
				case ''' + CONVERT(varchar(10),@CompanyID) + '''
					when ''' + '0' + ''' then isnull(s.HospitalID,''' + ''')
					else ''' + CONVERT(varchar(10),@CompanyID) + '''
				end
		'

	exec (@query)
END


   