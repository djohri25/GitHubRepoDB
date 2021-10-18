/****** Object:  Procedure [dbo].[Get_NPI_Details_By_Group]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[Get_NPI_Details_By_Group]
@DBNAME varchar(500) ,
@GroupName varchar(500)
as
DECLARE @ID varchar(100);
DECLARE @FullName varchar(50);
DECLARE @FirstName varchar(500),@MiddleName varchar(500),@LastName varchar(500), @NPIList varchar(max);
DECLARE @sql varchar(8000);

DECLARE @sql2 varchar(8000);
declare @tempHP table (field varchar(100))
select @sql = 'select id from [VD-APP01].' + @DBNAME + '.dbo.MDGroup where GroupName = ''' + @GroupName + ''''
--SELECT @sql
insert into @tempHP
exec (@sql)
Select @ID = field FROM @tempHP th
--SELECT @ID
SELECT @sql2 = 'SELECT  ma.NPI,n.[Provider Last Name (Legal Name)] + '' '' + n.[Provider First Name] AS FullName
from Link_MDGroupNPI ma inner join [VD-APP01].' + @DBNAME +'.dbo.LookupNPI n on ma.NPI = n.NPI
where MDGroupID = ' +@ID
DECLARE @tempNPI table(NPI varchar(8000),FullName varchar(5000))
insert into @tempNPI
exec (@sql2)
SELECT * FROM @tempNPI tn