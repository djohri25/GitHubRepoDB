/****** Object:  Procedure [dbo].[Rpt_LabDataSubreport]    Committed by VersionSQL https://www.versionsql.com ******/

/*====================================================================================================================
change:
date: 0715
author: Luna
Description: modify for ABCBS

EXECUTE [dbo].[Rpt_LabDataSubreport] '10TT298753',NULL 
=====================================================================================================================*/


CREATE PROCEDURE [dbo].[Rpt_LabDataSubreport]  
@ICENUMBER VARCHAR (15), @ReportType VARCHAR (15)=null  
AS  
SET NOCOUNT ON  
BEGIN  
declare @limitDate datetime  
  


  /*comment out Luna 0715
--Declare @ICEGroup varchar(50)  
--Select @ICEGroup = IceGroup from [dbo].[MainICENUMBERGroups]  
--where IceNumber = @ICENUMBER  
  
--Create Table #IceNumbers (IceNumber varchar(50))  
--Insert #IceNumbers  
--Select IceNumber from [dbo].[MainICENUMBERGroups]  
--where IceGroup = @ICEGroup 
 */ 

 -- THIS WILL BE MVDID FROM [dbo].[LinkMemberMVDID] 
Create Table #IceNumbers (MVDID varchar(50))  
Insert #IceNumbers  
Select MVDID from [dbo].[FinalLab] 


  
if(LEN(ISNULL(@ReportType,'')) > 0 and @ReportType = '21')  
	BEGIN  
		SET @LIMITDATE = DATEADD(DD,-60, GETDATE())  
	END  
ELSE  
	BEGIN  
		SET @LIMITDATE = '1/1/1900'  
	END  
  
SELECT distinct  LReq.MVDID,
				LReq.RecordID, --orderid
				isnull(OrderName,'') as Request,  
				[OrderingPhysicianName] as RequestingPhysician, 
				[OrderDate],--RequestDate 
				--CASE WHEN (ISNULL(LReq.UpdatedBy,'') = '' and ISNULL(LReq.UpdatedByOrganization,'') = '') THEN Substring(Lreq.CreatedBy+',',1, CHARINDEX(',',Lreq.CreatedBy+',')-1)  
				--	 WHEN UPPER(LReq.UpdatedBy) = 'PATIENT' then ''  
				--ELSE Substring(LReq.UpdatedBy+',',1, CHARINDEX(',',LReq.UpdatedBy+',')-1) 				
				''			AS UpdatedBy,  
				-- update after next move updatedate 0715
				--CASE WHEN (ISNULL(LReq.UpdatedBy,'') = '' and ISNULL(LReq.UpdatedByOrganization,'') = '') THEN Lreq.CreatedByOrganization  
				--	 WHEN UPPER(LReq.UpdatedBy) = 'PATIENT' then ''  
				--ELSE LReq.UpdatedByOrganization END UpdatedByOrganization,  
				''			AS UpdatedByOrganization,
				--LReq.UpdatedByContact UpdatedByContact,  
				''			AS UpdatedByContact,
				LReq.LabDataSource ,
				isnull(TestName,'') 
						+ isnull(' (' + TestCode + ')','')  
						+ isnull(': ' + TestResult,'') 
						+ isnull(' ' + ResultUnit,'')  
						+ case isnull([RefInterpretationFlag],'')   when '' then ''  else ' (' + [RefInterpretationFlag] + ')' 
				END																	AS ResultFull,     
				isnull(TestName,'') + isnull(' (' + TestCode + ')','')				AS ResultName,    
				''																	AS ResultInRange,    
				''																	AS ResultOutOfRange,    
				isnull([ReferenceRange],'')											AS ReferenceRange,    
				ResultUnit															AS Unit,    
				''																	AS ResultDate,  
				--will update after next move createdate 0715
				[RefInterpretationFlag],   
				--LRes.resultID,
				''																	AS ResultID,
				--LNote.Note
				[ResultNote]														AS NOTE
FROM [dbo].[FinalLab]  LREQ 
--LEFT JOIN dbo.MainLabResult LRes 
--	ON LReq.ICENUMBER = LRes.ICENUMBER 
--	and LReq.OrderID = LRes.OrderID 
--	and LReq.SourceName = LRes.SourceName
--LEFT JOIN dbo.MainLabNote  LNote 
--	ON LNote.ICENUMBER = LRes.ICENUMBER 
--	and LRes.ResultID = LNote.resultID 
--	and LRes.sourceName = LNote.sourceName 
--	and isnull(note,'') <> ''
WHERE 
	 LREQ.MVDID in (Select MVDID From #IceNumbers)    
	 AND LREQ.OrderDate > @limitDate  
ORDER BY OrderDate desc  

END