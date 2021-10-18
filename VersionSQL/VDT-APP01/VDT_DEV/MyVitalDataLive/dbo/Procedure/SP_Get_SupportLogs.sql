/****** Object:  Procedure [dbo].[SP_Get_SupportLogs]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].SP_Get_SupportLogs 
	@StatusFilter varchar(15)
AS

SET NOCOUNT ON

if( len(@StatusFilter)=0)
begin
	SELECT Row_Number() OVER(order by Created) as rowNumber,
		RecordID,Agent_FirstName,Agent_LastName,
		CASE ISNULL(CallDate,'')
			WHEN '' THEN NULL
			ELSE 
			(
				CONVERT(VARCHAR(30),ISNULL(CallDate,''),101)
			)
		END AS CallDate,
		CallTime,
		(select CategoryName from dbo.LookupCS_Category b where b.CategoryID=Category) as Category,
		Reporter_FirstName,Reporter_LastName,MVDId,
		(select StatusName from dbo.LookupCS_Status b where b.StatusID=Status) as Status,
		Comments 
	from dbo.CustomerSupportLog
end
else
begin
	SELECT Row_Number() OVER(order by Created) as rowNumber,
		RecordID,Agent_FirstName,Agent_LastName,
		CASE ISNULL(CallDate,'')
			WHEN '' THEN NULL
			ELSE 
			(
				CONVERT(VARCHAR(30),ISNULL(CallDate,''),101)
			)
		END AS CallDate,
		CallTime,
		(select CategoryName from dbo.LookupCS_Category b where b.CategoryID=Category) as Category,
		Reporter_FirstName,Reporter_LastName,MVDId,
		(select StatusName from dbo.LookupCS_Status b where b.StatusID=Status) as Status,
		Comments 
	from dbo.CustomerSupportLog a
	where status = @StatusFilter
	
end