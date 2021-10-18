/****** Object:  Procedure [dbo].[Get_Diag_Codes]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Get_Diag_Codes]
	@SelectedParents varchar(max),
	@SelectedGroups varchar(max)
AS
BEGIN
	SET NOCOUNT ON;

--select @selectedparents = '104|106',
--	@selectedgroups = '1|E'


	declare @tempSelectedParents table (data varchar(50))
	declare @tempSelectedGroups table (data varchar(50))

	insert into @tempSelectedParents (data)
	select data from dbo.Split(@SelectedParents,'|')

	insert into @tempSelectedGroups (data)
	select data from dbo.Split(@SelectedGroups,'|')
	
	declare @tempGroups table (name varchar(10))
	
	insert into @tempGroups
	select data from dbo.Split('0|1|2|3|4|5|6|7|8|9|E|V','|')
	
	select 
		convert(xml,(	    
			select name + 'XX' as name, name as ID,
				convert(xml,(	    
				SELECT rtrim( ISNULL( code,'') ) as 'Code', rtrim( ISNULL( code,'') ) + '.XX - ' + b.MediumDesc as 'Name',
					(
						convert(xml,(SELECT rtrim(subd.code)  as 'Code', rtrim( ISNULL( subd.code,'') ) + ' - ' + MediumDesc as 'Name'
								from [LookupICD9] subd
							where subd.Code like rtrim(b.code) + '%' and b.code in (select data from @tempSelectedParents)
							  FOR XML RAW ('DiagSub'))) 
					)
				FROM [LookupICD9] b 
				WHERE b.code not like '%.%' and b.Code like gr.name + '%' and gr.name in (select data from @tempSelectedGroups)
				FOR XML RAW ('DiagParent')
				)) 			
			
			FROM @tempGroups gr 
			FOR XML RAW ('Group')	
		))	as 'DiagCodes'
	for xml path(''), type, elements

/*		

	select 
		convert(xml,(	    
			select name + '**' as name, name as ID,
				convert(xml,(	    
				SELECT rtrim( ISNULL( code,'') ) as 'Code', rtrim( ISNULL( code,'') ) + ' - ' + MediumDesc as 'Name',
					(
						convert(xml,(SELECT rtrim(subd.code)  as 'Code', rtrim( ISNULL( subd.code,'') ) + ' - ' + MediumDesc as 'Name'
								from [LookupICD9] subd
							where subd.Code like rtrim(b.code) + '.%' and b.code in (select data from @tempSelectedParents)
							  FOR XML RAW ('DiagSub'))) 
					)
				FROM [LookupICD9] b 
				WHERE b.code not like '%.%' and b.Code like gr.name + '%' and gr.name in (select data from @tempSelectedGroups)
				FOR XML RAW ('DiagParent')
				)) 			
			
			FROM @tempGroups gr 
			FOR XML RAW ('Group')	
		))	as 'DiagCodes'
	for xml path(''), type, elements

	select 
		convert(xml,(	    
		SELECT rtrim( ISNULL( code,'') ) as 'Code', rtrim( ISNULL( code,'') ) + ' - ' + MediumDesc as 'Name',
			(
--				case 
--					when len(@SelectedParents) > 0 then (
						convert(xml,(SELECT rtrim(subd.code)  as 'Code', rtrim( ISNULL( subd.code,'') ) + ' - ' + MediumDesc as 'Name'
								from [LookupICD9] subd
							where subd.Code like rtrim(b.code) + '.%' and b.code in (select data from @tempSelected)
							  FOR XML RAW ('DiagSub'))) 
--					)
--				end
			)
		FROM [LookupICD9] b 
		WHERE code not like '%.%'
		FOR XML RAW ('DiagParent')
		)) as 'DiagCodes'
	for xml path(''), type, elements

*/

/*
	select 
		convert(xml,(	    
		SELECT top 10 rtrim( ISNULL( code,'') ) as 'Code', rtrim( ISNULL( code,'') ) + ' - ' + MediumDesc as 'Name',
			(
			convert(xml,(SELECT rtrim(subd.code)  as 'Code', rtrim( ISNULL( subd.code,'') ) + ' - ' + MediumDesc as 'Name'
					from [LookupICD9] subd
				where subd.Code like rtrim(b.code) + '.%'
				  FOR XML RAW ('DiagSub'))) 
			)
		FROM [LookupICD9] b 
		WHERE code not like '%.%'
		FOR XML RAW ('DiagParent')
		)) as 'DiagCodes'
	for xml path(''), type, elements
*/

/*
    SELECT 						
	--	getutcdate() as attNode,
	(	
		SELECT top 10 rtrim( ISNULL( code,'') ) as DIAGNOSISPARENT,
			isnull((SELECT rtrim(subd.code) as 'SUBDIAGNOSIS'
					from [LookupICD9] subd
				where subd.Code like rtrim(b.code) + '.%'
				  FOR XML PATH(''),TYPE, ELEMENTS
				),'') AS  SUBDIAGNOSIS						
		FROM [LookupICD9] b 
		WHERE code not like '%.%'
		FOR XML PATH('DIAGNOSIS'),TYPE, ELEMENTS
	)FOR XML RAW ('CODES'), TYPE
*/
END