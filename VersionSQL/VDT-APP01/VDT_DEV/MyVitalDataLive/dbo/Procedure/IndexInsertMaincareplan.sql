/****** Object:  Procedure [dbo].[IndexInsertMaincareplan]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[IndexInsertMaincareplan] (@mvdid nvarchar(50),@careplandate date,@author nvarchar(50),@createdby nvarchar(50) )

AS 

BEGIN 

    SET NOCOUNT ON;
	
CREATE TABLE #TempQuestions 
(Id int identity(1,1),
MVDID varchar(20),
Questions varchar(max), 
Answers varchar(max)) 
	
	
INSERT INTO #TempQuestions (Questions)

	SELECT	COLUMN_NAME 
                                        FROM INFORMATION_SCHEMA.COLUMNS
                                        WHERE TABLE_NAME = 'hra_form' 
                                        AND 
                                        TABLE_SCHEMA='dbo' and COLUMN_NAME not in ('ID',
'MVDID',
'FormDate',
'FormAuthor',
'CaseID')

--select * from #TempQuestions


declare @id int 
select @id = max(id) from [HRA_Form]

CREATE TABLE #TempAnswers (Id int identity(1,1),mvdid varchar(20), Answers varchar(max))

insert into #TempAnswers (mvdid,Answers)

 select  mvdid ,  answers 
  FROM
  ( select 
	   id
	  ,mvdid
	  ,[q1Info]
      ,[q2GenHealth]
      ,[q3MedAttorney]
      ,[q4HCWishes]
      ,[q5PCP]
      ,[q6PCPVisit]
      ,[q7BP]
      ,[q8cholesterol]
      ,[q9sugar]
      ,[q10Ill]
      ,[q11PainScale]
      ,[q12Tobacco]
      ,[q13Alcohol]
      ,[q14]
      ,[q15]
      ,[q16]
      ,[q17NeedAssistance]
      ,[q18HealthyDiet]
      ,[q19TeethCondition]
      ,[q20Exercise]
      ,[q21fallen]
      ,[q22EveryDayActivities]
      ,[q23]
      ,[q23a]
      ,[q24]
      ,[q25Depress]
      ,[q26Interest]
      ,[q27support]
      ,[q28]
      ,[q29Snore]
      ,[q30Sleepy]
      ,[q31HealthGoals]
      ,[q31aOther]
  FROM [dbo].[HRA_Form] where id=@id ) as cp

  unpivot 
  (
   answers for answerss in ([q1Info]
      ,[q2GenHealth]
      ,[q3MedAttorney]
      ,[q4HCWishes]
      ,[q5PCP]
      ,[q6PCPVisit]
      ,[q7BP]
      ,[q8cholesterol]
      ,[q9sugar]
      ,[q10Ill]
      ,[q11PainScale]
      ,[q12Tobacco]
      ,[q13Alcohol]
      ,[q14]
      ,[q15]
      ,[q16]
      ,[q17NeedAssistance]
      ,[q18HealthyDiet]
      ,[q19TeethCondition]
      ,[q20Exercise]
      ,[q21fallen]
      ,[q22EveryDayActivities]
      ,[q23]
      ,[q23a]
      ,[q24]
      ,[q25Depress]
      ,[q26Interest]
      ,[q27support]
      ,[q28]
      ,[q29Snore]
      ,[q30Sleepy]
      ,[q31HealthGoals]
      ,[q31aOther])
  
  ) as up

  update Q
  SET q.Answers=a.Answers,
  q.MVDID=a.mvdid
  from #TempQuestions Q
  INNER JOIN #TempAnswers A
   on q.Id=a.Id

   select 
   q.MVDID,
   l.cplinknumber as cplinknumber, 
   l.cpprobnum as cpprobnum,
   l.cpassessmentid as cpassessmentid, 
   l.cpAssessmentQuestion as cpAssessmentQuestion,	
   l.cpAssessmentResponse as cpAssessmentResponse,
   q.Answers as Answers
into #TempQA
   from #TempQuestions q
   inner join  CarePlanLibraryAssessmentLink l
on q.Questions=l.cpAssessmentQuestion
and l.cpLinkNumber is not null 


UPDATE #TempQA SET cpAssessmentResponse='' 
WHERE cpAssessmentQuestion='q10Ill' and cpAssessmentResponse=  '< '' '''

UPDATE #TempQA SET cpAssessmentResponse='' 
WHERE cpAssessmentQuestion='q5PCP' and cpAssessmentResponse=  '< '' '''


  select 
MVDID,cplinknumber,cpprobnum,cpassessmentid,cpAssessmentQuestion, replace(replace(replace(replace(replace(replace(cpAssessmentResponse,'= ''',''),'''',''),'like %',''),'?%','?'),'< ',''),'> ','') as cpAssessmentResponse, replace(replace(replace(Answers,'[',''),']',''),'"','') as Answers
into #TempQAScrubbed
from #TempQA



update s

 set 
    cpAssessmentResponse = (case when cast(s.Answers as int)>10 and m.GenderID =1  then s.Answers
							     when cast(s.Answers as int)>7 and m.GenderID =2  then s.Answers
																			else 'No Match' end)
FROM #TempQAScrubbed s
inner join MainPersonalDetails m 
on m.ICENUMBER= s.MVDID
where s.cpAssessmentQuestion='q13Alcohol'

update s
 set 
    cpAssessmentResponse = (case when cast(s.Answers as int)>3  then s.Answers
							     	else 'No Match' end)
FROM #TempQAScrubbed s
where s.cpAssessmentQuestion='q11PainScale'

update s
 set 
    cpAssessmentResponse = (case when cast(s.Answers as int)>30  then s.Answers
							     	else 'No Match' end)
FROM #TempQAScrubbed s
where s.cpAssessmentQuestion='q16' and cpprobnum=13

update s
 set 
    cpAssessmentResponse = (case when cast(s.Answers as int)<22  then s.Answers
							     	else 'No Match' end)
FROM #TempQAScrubbed s
where s.cpAssessmentQuestion='q16' and cpprobnum=14

update s
 set 
    cpAssessmentResponse = (case when s.Answers ='Fair'  then s.Answers
								 when Answers='Poor' then s.Answers
							     	else 'No Match' end)
FROM #TempQAScrubbed s
where s.cpAssessmentQuestion='q19TeethCondition' 

update s
 set 
    cpAssessmentResponse = (case when s.Answers in ('Less than 3','Not at all')  then s.Answers
								 							     	else 'No Match' end)
FROM #TempQAScrubbed s
where s.cpAssessmentQuestion='q20Exercise' 

update s
 set 
    cpAssessmentResponse = (case when s.Answers like 'Almost all'  then s.Answers
								 when s.Answers like 'Most'  then s.Answers
								 							     	else 'No Match' end)
FROM #TempQAScrubbed s
where s.cpAssessmentQuestion='q25Depress' 

update s
 set 
    cpAssessmentResponse = (case when s.Answers in ('Fair','Poor')  then s.Answers
								 else 'No Match' end)
FROM #TempQAScrubbed s
where s.cpAssessmentQuestion='q2GenHealth' 

update s
 set 
    cpAssessmentResponse = (case when s.Answers in ('No','Don’t know/Unsure')  then s.Answers
								 							     	else 'No Match' end)
FROM #TempQAScrubbed s
where s.cpAssessmentQuestion='q6PCPVisit'

update s
 set 
    cpAssessmentResponse = (case when s.Answers in ('No','Don’t know/Unsure')  then s.Answers
								 							     	else 'No Match' end)
FROM #TempQAScrubbed s
where s.cpAssessmentQuestion='q7BP'

update s
 set 
    cpAssessmentResponse = (case when s.Answers in ('No','Don’t know/Unsure')  then s.Answers
								 							     	else 'No Match' end)
FROM #TempQAScrubbed s
where s.cpAssessmentQuestion='q8cholesterol'

update s
 set 
    cpAssessmentResponse = (case when s.Answers in ('No','Don’t know/Unsure')  then s.Answers
								 							     	else 'No Match' end)
FROM #TempQAScrubbed s
where s.cpAssessmentQuestion='q9sugar'

update s
 set 
    Answers = (case when s.Answers like '%Establish an advance directive and Goals of Care?%'  then s.Answers
					when s.Answers like '%Increase your level of physical activity?%'  then s.Answers
					when s.Answers  like '%Eat healthier?%'  then s.Answers
					when s.Answers  like '%Lose (or gain) weight?%'  then s.Answers
					when s.Answers  like '%Lose (or gain) weight?%'  then s.Answers
					when s.Answers  like '%Reduce alcohol consumption?%'  then s.Answers
					when s.Answers  like '%Quit using tobacco products?%'  then s.Answers
					when s.Answers  like '%Learn how to manage your depression, stress or anxiety?%'  then s.Answers
					when s.Answers  like '%Learn how to  improve your sleep?%'  then s.Answers
					when s.Answers  like '%Maintain or increase your ability to perform everyday activities, such as eating and getting dressed?%'  then s.Answers
					when s.Answers  like '%Learn how to maintain or improve your memory and mental clarity?%'  then s.Answers
					when s.Answers  like '%Learn how to  avoid falls?%'  then s.Answers
					when s.Answers  like '%Reduce your pain?%'  then s.Answers
								 							     	else 'No Match' end)
FROM #TempQAScrubbed s
where s.cpAssessmentQuestion='q31HealthGoals'


select ts.MVDID as MVDID,ts.cplinknumber as cplinknumber,ts.cpprobnum as cpprobnum,ts.cpassessmentid as cpassessmentid,ts.cpAssessmentQuestion as cpAssessmentQuestion,ts.cpAssessmentResponse as cpAssessmentResponse,ts.Answers as Answers
into #tempMatchedOutput
from #TempQAScrubbed ts 
inner join 
#TempQAScrubbed tqs
on ts.cplinknumber=tqs.cplinknumber
and ts.cpprobnum=tqs.cpprobnum and ts.cpAssessmentResponse = tqs.Answers


DECLARE @COUNT INT
--DECLARE @MVDID NVARCHAR(50)
DECLARE @CUSTID NVARCHAR(50)
DECLARE @cpLibraryID INT
DECLARE @IDENTITY INT 

select @CUSTID=max(Cust_ID) from dbo.Link_MemberId_MVD_Ins where MVDID=@MVDID
SET @cpLibraryID=1

select @COUNT= COUNT(Answers)
from #tempMatchedOutput

--SELECT @MVDID=MAX(@MVDID) FROM #TempQAScrubbed

IF (@COUNT>0)
BEGIN 

if not exists (select 1 from MainCarePlanMemberIndex where MVDID=@mvdid)

BEGIN
 INSERT INTO [dbo].[MainCarePlanMemberIndex]
           ([Cust_ID]
           ,[MVDID]
           ,[cpLibraryID]
           ,[CarePlanDate]
           ,[Author]
           ,[Language]
           ,[CaseID]
           ,[cpInactiveDate]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[UpdatedDate]
           ,[UpdatedBy])
SELECT 
			@CUSTID
		   ,@MVDID
		   ,@cpLibraryID
		   ,@careplandate
		   ,@author
		   ,NULL AS LANGUAGE
		   ,NULL AS CASEID
		   ,NULL AS CPINACTIVEDATE
		   ,@careplandate
		   ,@author
		   ,@careplandate
		   ,@author

	SELECT @IDENTITY = SCOPE_IDENTITY()

--INSERTING WHEN IT DOESNT EXISTS  
		Insert into dbo.MainCarePlanMemberProblems 
			  ([CarePlanID]
			  ,[seq]
			  ,[idDate]
			  ,[priority]
			  ,[problemNum]
			  ,[problemFreeText]
			  ,[status]
			  ,[cpInactiveDate]
			  ,[CreatedDate]
			  ,[CreatedBy]
			  ,[UpdatedDate]
			  ,[UpdatedBy]
			  ,[Optionality]
			  ,[Comments])

			  select @IDENTITY as CarePlanID,
					 -1 as seq,
					 @CarePlanDate AS idDate,
					 0 AS [priority],
					 p.cpProbNum as problemNum,
					 cpProbText as problemFreeText,
					 0 as status,
					 null as cpInactiveDate,
					 @careplandate as CreatedDate,
					 @author as CreatedBy,
					 @careplandate as UpdatedDate,
					 @author as UpdatedBy,
					 0 as Optionality,
					 null as comments 
			 FROM dbo.[CarePlanLibraryProblems] p
			 inner join (select distinct cpprobnum from #tempMatchedOutput) o
			 on p.cpProbNum=o.cpprobnum

		--INSERT GOALS
		--INSERT INTERVENTIONS
		    
END

IF exists (select 1 from MainCarePlanMemberIndex where MVDID=@mvdid)

BEGIN 

DECLARE @CAREPLANID INT, @createddate datetime
SELECT @CAREPLANID= MAX(CAREPLANID)  from MainCarePlanMemberIndex where MVDID=@mvdid
SELECT @createddate= createddate  from MainCarePlanMemberIndex where CAREPLANID=@CAREPLANID


		Insert into dbo.MainCarePlanMemberProblems 
			  ([CarePlanID]
			  ,[seq]
			  ,[idDate]
			  ,[priority]
			  ,[problemNum]
			  ,[problemFreeText]
			  ,[status]
			  ,[cpInactiveDate]
			  ,[CreatedDate]
			  ,[CreatedBy]
			  ,[UpdatedDate]
			  ,[UpdatedBy]
			  ,[Optionality]
			  ,[Comments])

			  select @CarePlanID as CarePlanID,
					 -1 as seq,
					 @CarePlanDate AS idDate,
					 0 AS [priority],
					 p.cpProbNum as problemNum,
					 cpProbText as problemFreeText,
					 0 as status,
					 null as cpInactiveDate,
					 @CreatedDate as CreatedDate,
					 @author as CreatedBy,
					 @CreatedDate as UpdatedDate,
					 @author as UpdatedBy,
					 0 as Optionality,
					 null as comments 
			 FROM dbo.[CarePlanLibraryProblems] p
			 inner join (select distinct cpprobnum from #tempMatchedOutput) o
			 on p.cpProbNum=o.cpprobnum

			 --insert goals 
			 --insert interventions
END 

END

END