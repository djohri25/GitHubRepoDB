/****** Object:  Procedure [dbo].[Set_MDActionNote]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		
-- Create date: 5/1/2012
-- Description:	Create new MD note about user action
-- =============================================
create PROCEDURE [dbo].[Set_MDActionNote]
	@MvdID varchar(15),
	@Action varchar(50),
	@MemberStatusList varchar(50),
	@UserID varchar(50),
	@Result int out
AS
BEGIN
	SET NOCOUNT ON;
	
	--select @MvdID = 'mmmssss',
	--	@Action = 'VIEWRECORD_PDF_SUMMARY',
	--	@MemberStatusList = '1,2,3',
	--	@UserID = 'sales'
	
	declare @Text varchar(max)

	set @Text = ''
	
	if(@Action = 'VIEWRECORD')
	begin
		declare @temp table (statusId varchar(10))
		
		insert into @temp(statusId)
		select data from dbo.Split(@MemberStatusList,',')
		
		if exists (select statusId from @temp where statusId = '4')
		begin 
			set @Text = 'ER Visited Alert'
		end

		if exists (select statusId from @temp where statusId = '3')
		begin 
			if(LEN(@Text) > 0)
			begin
				set @Text = @Text + ' and '
			end
			
			set @Text = @Text + 'Data Updated Alert'			
		end
		
		if(LEN(@Text) = 0)
		begin
			set @Text = 'Record viewed.'
		end
		else
		begin
			set @Text = @Text + ' viewed.'
		end		
	end
	else if(@Action = 'VIEWRECORD_PDF_DETAILED')
	begin
		set @Text = 'Detailed Report Viewed.'
	end
	else if(@Action = 'VIEWRECORD_PDF_SUMMARY')
	begin
		set @Text = 'Summary Report Viewed.'
	end
	
	select @Text
	
	insert into hpAlertNote (alertID,Note,alertStatusID,datecreated,createdby,createdByType,datemodified,modifiedby,modifiedByType, MVDID)
	values(null,@Text,null,getutcdate(),@UserID,'MD',getutcdate(),@UserID,'MD', @mvdid)
		
	set @Result = 0
			
END