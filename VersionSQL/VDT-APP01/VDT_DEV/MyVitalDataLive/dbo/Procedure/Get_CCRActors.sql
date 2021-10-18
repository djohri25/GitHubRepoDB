/****** Object:  Procedure [dbo].[Get_CCRActors]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		sw
-- Create date: 5/4/2009
-- Description:	Returns list of all actors related to 
--	current CCR
-- =============================================
CREATE PROCEDURE [dbo].[Get_CCRActors]
	@actorList xml output
AS
BEGIN
	SET NOCOUNT ON;

	set @actorList = ''


	if exists(select id from #tempActors)
	begin
   		select @actorList =
		(
			select 
				id as ActorObjectID,
				(
					select 
						case convert(varchar, actorType,5)
						when '1' -- Person
						then
						(
							select firstName as 'Name/CurrentName/Given',
								LastName as 'Name/CurrentName/Family',
								Credentials as 'Name/CurrentName/Title'
							for xml path('Person'), type, elements
						)
						else -- Organization
						(
							select organizationName as [Name]
							for xml path('Organization'), type, elements
						)end
					for xml path(''), type, elements
				),
				(
					case isnull(NPI,'')
					when '' then null
					else 
					(
						select	
							(select 'NPI' as [Text]
							FOR XML PATH('Type'), TYPE, ELEMENTS),
							NPI as ID,
							dbo.Get_CCRFormatSource(IDProvider,null)
						FOR XML PATH(''), TYPE, ELEMENTS								
					)
					END
				) as IDs,						
				(
					-- If any part of address is present include the Address node
					case isnull(Address1,'') + isnull(Address1,'') + isnull(City,'') + isnull(State,'') + isnull(Zip,'')
					when '' then null
					else 
					(
						select	
							(
								select 
									'Office' as [Text]
								FOR XML PATH('Type'), TYPE, ELEMENTS
							),
							Address1 as Line1,
							case isnull(Address2,'')
								when '' then null
								else(Address2)
							end as Line2,
							City as City,
							State,
							'USA' as Country,
							Zip as PostalCode									
						FOR XML PATH(''), TYPE, ELEMENTS								
					)
					END
				) as Address,
				(
					case isnull(Phone,'')
					when '' then null
					else 
					(
						select Phone as [Value],
						(
							select 'Office' as [Text]
							FOR XML PATH('Type'), TYPE, ELEMENTS
						)
						FOR XML PATH(''), TYPE, ELEMENTS								
					)
					END
				) as Telephone,		
				dbo.Get_CCRFormatSource(DataProvider,null)
			from #tempActors 	
			where ActorRole is null OR ActorRole <> 'Patient'			-- Patient is retrieved by different store proc	 			
			FOR XML PATH('Actor'), TYPE, ELEMENTS	
		)
	end
END