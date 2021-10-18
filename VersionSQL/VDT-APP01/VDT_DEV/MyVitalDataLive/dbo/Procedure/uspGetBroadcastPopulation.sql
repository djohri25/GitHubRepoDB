/****** Object:  Procedure [dbo].[uspGetBroadcastPopulation]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		dpatel
-- Create date: 05/27/2020
-- Description:	Get broadcast population.
-- =============================================
CREATE PROCEDURE [dbo].[uspGetBroadcastPopulation] 
	@ThreadPopulationId int,
	@ReferralReason varchar(250) = null,
	@CustomerId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @brdPopulation varchar(250);

	select @brdPopulation = Label_Desc
	from Lookup_Generic_Code where CodeID = @ThreadPopulationId;
	
	if @brdPopulation <> 'All Members'
		begin
			if @ReferralReason is null
				begin
					select distinct MVDID 
					from dbo.[ABCBS_MemberManagement_Form] 
					where CaseProgram=@brdPopulation
						and InProgress='No' 
						and ISNULL(qCloseCase,'No') <> 'Yes' 
						and ISNULL(CaseID,'') <> ''
						and CAST(SectionCompleted as int) < 3;
				end
			else
				begin
					select distinct MVDID 
					from dbo.[ABCBS_MemberManagement_Form] 
					where CaseProgram=@brdPopulation
						and ISNULL(ReferralReason, '') = @ReferralReason
						and InProgress='No' 
						and ISNULL(qCloseCase,'No') <> 'Yes' 
						and ISNULL(CaseID,'') <> ''
						and CAST(SectionCompleted as int) < 3;
				end
			
		end
	else
		begin
			select MVDID
			from ComputedCareQueue
			where Isactive = 1
		end
END