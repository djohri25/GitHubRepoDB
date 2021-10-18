/****** Object:  Procedure [dbo].[ProblemsInsertMaincareplan]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[ProblemsInsertMaincareplan] 
(@CarePlanID bigint, --THIS ID IS FROM IDENTITY COLUMN CAREPLANID FROM MainCarePlanMemberIndex
@seq int = 0,
@CarePlanDate date NULL, --THIS DATE IS FROM MainCarePlanMemberIndex
@priority smallint = 0,
@problemNum int = NULL,
@problemFreeText varchar(max) = NULL,
@status bit = 0,
@cpInactiveDate date = NULL,
@CreatedDate datetime,
@CreatedBy nvarchar(50),
@UpdatedDate datetime = NULL,
@UpdatedBy nvarchar(50) = NULL,
@Optionality int =0,
@Comments nvarchar (max) =NULL,
@goalnum bigint =null,
@goalFreeText varchar (max) =null,
@intnum bigint = null,
@intFreeText varchar (max) =null,
@goaltype char(1)=null,
@outcome int= 0,
@targetdate date =null,
@CompleteDate date=null,	
@Comment varchar(max)=null,	
@ProblemID bigint output)


	AS 
BEGIN 

	SET NOCOUNT ON;

IF (@problemNum <>0)

BEGIN

IF EXISTS (SELECT 1 FROM dbo.MainCarePlanMemberProblems WHERE CarePlanID=@CarePlanID AND problemNum= 
(SELECT CPPROBNUM FROM dbo.[CarePlanLibraryProblems] WHERE CPPROBNUM=@problemNum))

BEGIN
			SELECT '*** Already on file ***'  --NEED TO CAPTURE THIS IN A VARIABLE
END 

ELSE

	BEGIN 

	IF @seq =0
	SET @seq=-1

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
					 @seq as seq,
					 @CarePlanDate AS idDate,
					 @priority AS [priority],
					 cpProbNum as problemNum,
					 cpProbText as problemFreeText,
					 @status as status,
					 null as cpInactiveDate,
					 @CreatedDate as CreatedDate,
					 @CreatedBy as CreatedBy,
					 @UpdatedDate as UpdatedDate,
					 @UpdatedBy as UpdatedBy,
					 @Optionality as Optionality,
					 @Comments as comments 
			 FROM dbo.[CarePlanLibraryProblems] 
			 WHERE cpProbNum=@problemNum
	 

			set @ProblemID = SCOPE_IDENTITY()

select distinct @ProblemID as ProblemID,  g.cpProbNum as cpProbNum ,g.cpGoalNum as cpGoalNum, 
g.cpGoalType as cpGoalType, g.cpGoalText as cpGoalText, g.cpGoalActiveDate as cpGoalActiveDate, 
p.CreatedDate as CreatedDate, p.CreatedBy as CreatedBy, p.UpdatedBy as UpdatedBy, p.UpdatedDate as UpdatedDate
into #TempGoals
from [dbo].[CarePlanLibraryGoals] g
inner join MainCarePlanMemberProblems p
on g.cpProbNum=p.problemNum  
where p.CarePlanID=@CarePlanID and p.ID=@ProblemID



 INSERT INTO [MainCarePlanMemberGoals] 
 (     [ProblemID]
      ,[seq]
      ,[GoalNum]
      ,[goalFreeText]
      ,[goalType]
      ,[Outcome]
      ,[TargetDate]
      ,[CompleteDate]
      ,[Comment]
      ,[cpInactiveDate]
      ,[CreatedDate]
      ,[CreatedBy]
      ,[UpdatedDate]
      ,[UpdatedBy])

select 
ProblemID,
@seq,
cpGoalNum,
cpGoalText,
cpGoalType,
@outcome,
@targetdate,
@CompleteDate,
@Comment,
@cpInactiveDate,
CreatedDate,
CreatedBy,
UpdatedDate,
UpdatedBy
from #TempGoals	  


select distinct 
g.ID as goalId,
g.GoalNum as GoalNum,
i.cpInterventionNum as cpInterventionNum,
i.cpInterventionText as cpInterventionText,
i.cpGoalNum as cpGoalNum,
g.CreatedDate as CreatedDate, 
g.CreatedBy as CreatedBy, 
g.UpdatedBy as UpdatedBy, 
g.UpdatedDate as UpdatedDate
into #TempInterventions
--from #TempGoals t 
from dbo.[MainCarePlanMemberGoals] g
inner join (select id, careplanid, problemnum from dbo.[MainCarePlanMemberProblems] where problemNum=@problemNum and careplanid=@CarePlanID ) p
on p.id=g.ProblemID
inner join dbo.CarePlanLibraryInterventions I
on g.GoalNum=i.cpGoalNum

INSERT INTO [dbo].[MainCarePlanMemberInterventions]
           ([GoalID]
           ,[seq]
           ,[InterventionNum]
           ,[interventionFreeText]
           ,[Outcome]
           ,[CompleteDate]
           ,[Comment]
           ,[cpInactiveDate]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[UpdatedDate]
           ,[UpdatedBy])

SELECT  goalId
	   ,@seq
	   ,@intnum
	   ,@intFreeText
	   ,@outcome
       ,@CompleteDate
       ,@Comment
       ,@cpInactiveDate
       ,[CreatedDate]
       ,[CreatedBy]
       ,[UpdatedDate]
       ,[UpdatedBy]
	from #TempInterventions
END 
END

IF (@problemNum =0 or @problemNum is null)

	--- THIS IS FOR THE CUSTOMIZE PROBLEM, PROBLEMNUM=0
--IF NOT EXISTS (SELECT 1 FROM dbo.MainCarePlanMemberProblems WHERE CarePlanID=@CarePlanID AND problemNum=@problemNum)
	BEGIN

DECLARE @goalID bigint 
	IF @seq =0
	SET @seq=-1
if @problemFreeText is null 
set @problemFreeText = '*** New Problem ***'



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

		SELECT 
		@CarePlanID,
		@seq,  
		@CarePlanDate,
		@priority,
		@problemNum,
		@problemFreeText,
		@status,
		@cpInactiveDate,
		@CreatedDate,
		@CreatedBy,
		@UpdatedDate,
		@UpdatedBy,
		@Optionality,
		@Comments
		

 SET @ProblemID= SCOPE_IDENTITY()

 /* NEED TO THINK IF WE NEED TO CONSIDER
 SELECT[ID]
      ,[CarePlanID]
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
      ,[Comments]
  FROM [dbo].[MainCarePlanMemberProblems]
		WHERE [ID] = @ProblemID
*/

-- ADDING ALL THE GOALS RELATED TO THE CUSTOMIZABLE PROBLEM 
if @goalnum=0 or @goalnum is null 
SET @goalnum =-1
set @goaltype ='S'
if @goalFreeText is null 
set @goalFreeText = '*** New Goal ***'


 INSERT INTO [MainCarePlanMemberGoals] 
 (     [ProblemID]
      ,[seq]
      ,[GoalNum]
      ,[goalFreeText]
      ,[goalType]
      ,[Outcome]
      ,[TargetDate]
      ,[CompleteDate]
      ,[Comment]
      ,[cpInactiveDate]
      ,[CreatedDate]
      ,[CreatedBy]
      ,[UpdatedDate]
      ,[UpdatedBy])

SELECT [ID]
      ,[seq]
	  ,@goalnum
	  ,@goalFreeText
	  ,@goaltype
	  ,@outcome
	  ,@targetdate
	  ,@CompleteDate
	  ,@Comment
      ,@cpInactiveDate
      ,[CreatedDate]
      ,[CreatedBy]
      ,[UpdatedDate]
      ,[UpdatedBy]
 FROM [MainCarePlanMemberProblems]
 WHERE  ID= @ProblemID 
  
  SELECT @goalID=ID FROM [MainCarePlanMemberGoals] WHERE ProblemID=@ProblemID--- NEED TO ADD THIS TO PARAMETER

if @intFreeText is null 
set @intFreeText = '*** New Intervention ***'
if @intnum =0 or @intnum is null 
set @intnum =-1


INSERT INTO [dbo].[MainCarePlanMemberInterventions]
           ([GoalID]
           ,[seq]
           ,[InterventionNum]
           ,[interventionFreeText]
           ,[Outcome]
           ,[CompleteDate]
           ,[Comment]
           ,[cpInactiveDate]
           ,[CreatedDate]
           ,[CreatedBy]
           ,[UpdatedDate]
           ,[UpdatedBy])

SELECT @goalID
	   ,@seq
	   ,@intnum
	   ,@intFreeText
	   ,[Outcome]
       ,[CompleteDate]
       ,[Comment]
       ,[cpInactiveDate]
       ,[CreatedDate]
       ,[CreatedBy]
       ,[UpdatedDate]
       ,[UpdatedBy]
	  from [MainCarePlanMemberGoals] where id=@goalID
END 

END