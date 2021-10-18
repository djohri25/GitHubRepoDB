/****** Object:  Procedure [dbo].[Ems_GetEmsHospital]    Committed by VersionSQL https://www.versionsql.com ******/

/***************************************************************************
* Created By: sw
* Date:  12/17/2008
* Purpose: Return the hospital for which user identified by "email" works
***************************************************************************/
CREATE procedure [dbo].[Ems_GetEmsHospital] 
(
	@email varchar(50),
	@userType varchar(50)
)
As
Begin
	declare @companyID int
	declare @companyName varchar(50)

	if(@userType = 'CONTACT')
	begin
		select @companyID = ID, @companyName = Name from mainemshospital where contactEmail = @email
	end
	else
	begin
		select @companyID = CompanyID, @companyName = Company from mainems where email = @email
	end

	if( (@companyID is null or @companyID = '') and  (@companyName is not null and @companyName <> '') )
	begin
		-- Try to identify the hospital by name
		select @companyID = ID from mainEMSHospital where Name = @companyName
	end

	SELECT ID
      ,Name
      ,Address
      ,City
      ,State
      ,Zip
      ,ContactName
      ,ContactEmail
      ,ContactPhone
      ,Website
      ,IP
      ,ApprovedDate
      ,Active
      ,CredentialsRequired
      ,AutoApprove
      ,Modified
      ,Created
	  ,isnull(MinorsAge,0) as MinorsAge
	FROM MainEMSHospital
	WHERE ID = @companyID
end