/****** Object:  Procedure [dbo].[Del_MergedRecord]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: 1/7/2011
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Del_MergedRecord]
	@MVDID varchar(20)
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @sql varchar(4000), @archiveDBName varchar(50)
	declare @temp table(data varchar(50))
	
	select @archiveDBName = dbo.Get_ArchiveDBName()	

	set @sql = 'select mvdid from ' + @archiveDBName + '.dbo.Link_MemberId_MVD_Ins where MVDId = ''' + @MVDID + ''''

	insert into @temp(data)
	EXEC (@sql)

	if exists(select DATA from @temp)	
	begin
		declare @icegroup varchar(20)
		
		IF @archiveDBName = 'MyVitalDataLive_Archive' 
		BEGIN
			select @icegroup = ICEGROUP
			from MyVitalDataLive_Archive.dbo.MainICENUMBERGroups
			where ICENUMBER = @MVDID	
		END
										
		DELETE from EDVisitHistory
        where ICENUMBER = @MVDID
        						
		DELETE from MainMedication
        where ICENUMBER = @MVDID
        
        DELETE from MainMedicationHistory
        where ICENUMBER = @MVDID
        
        DELETE from MainInsurance
        where ICENUMBER = @MVDID
        
        DELETE from MainCondition
        where ICENUMBER = @MVDID
        
        DELETE from MainCareInfo
        where ICENUMBER = @MVDID
        
        DELETE from MainSurgeries
        where ICENUMBER = @MVDID
        
		DELETE from MainSpecialist
        where ICENUMBER = @MVDID
        
        DELETE from MainLabRequest
        where ICENUMBER = @MVDID
        
        DELETE from MainLabResult
        where ICENUMBER = @MVDID
        
        DELETE from MainLabNote
        where ICENUMBER = @MVDID   
        
        DELETE from MainDiseaseManagement
        where ICENUMBER = @MVDID
		
		DELETE from UserAdditionalInfo
        where MVDID = @MVDID
       
		DELETE from SectionPermission 	
		where ICENUMBER = @MVDID
		
		DELETE from Link_HPMember_Doctor
		where MVDID = @MVDID		
		
		DELETE from MainPersonalDetails 
		where ICENUMBER = @MVDID		
	
		DELETE from MainICENUMBERGroups
		where ICENUMBER = @MVDID

		DELETE from MainICEGROUP
		where ICEGROUP = @icegroup
	end
END