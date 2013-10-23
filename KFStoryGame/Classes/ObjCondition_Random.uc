/*
	--------------------------------------------------------------
	Condition_Random
	--------------------------------------------------------------

    This Condition serves as a container for any number of other Conditions.
    when initalized, it picks one at random and activates it.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjCondition_Random extends KF_ObjectiveCondition
hidecategories(Difficulty,HUD,Events,KF_ObjectiveCondition)
editinlinenew;

var                 int                           RandIdx;

struct SRandomCondition
{
     var             () editinlineuse             KF_ObjectiveCondition   Condition;

     var             ()                           int                     Priority;
};

var                                               int                     ConditionIndex;

var (Conditions)                                  float                   PriorityBias;

var (Conditions)        editinlineuse             array<SRandomCondition> RandomConditions;



function ConditionActivated(pawn ActivatingPlayer)
{
     Super.ConditionActivated(ActivatingPlayer);
     ConditionIndex = GetObjOwner().FindIndexForCondition(self);
     AssignRandomCondition();
}

function Reset()
{
     super.Reset();
     SwapConditionAtIndex(ConditionType,self);
}

function AssignRandomCondition()
{
     local float HighestRating;
     local float PriorityVal;
	 local int				BestIdx;
	 local array<float>		Ratings;
	 local int i,idx;

	 HighestRating = -1;

	 for(i = 0 ; i < RandomConditions.length ; i ++)
	 {
	     if(!RandomConditions[i].Condition.bComplete)
	     {
		     PriorityVal = RandomConditions[i].Priority ;
		     Ratings[i] = RandRange( FMin(Ratings[idx] * PriorityBias,Ratings[idx]) , PriorityVal  ) ;
	     }
     }

	 for(idx = 0 ; idx < Ratings.length ; idx ++)
	 {
		 if(Ratings[idx] > highestRating )
		 {
			 BestIdx = idx;
			 HighestRating = Ratings[idx] ;
		 }
	 }

	 if(BestIdx < 0 || BestIdx >= RandomConditions.length)
	 {
         log("Warning -  Cannot find a valid Condition for : "@self@" Random Condition will fail. ",'Story_Debug');
	 }

     RandIdx = BestIdx;

     RandomConditions[RandIdx].Condition.ConditionType = ConditionType;
     RandomConditions[RandIdx].Condition.SetObjOwner(GetObjOwner());

    if(RandomConditions[RandIdx].Condition.ShouldInitOnActivation())
    {
       GetObjOwner().ActivateCondition(RandomConditions[RandIdx].Condition);

    }

     SwapConditionAtIndex(ConditionIndex,RandomConditions[RandIdx].Condition) ;
}

function SwapConditionAtIndex(int Index, KF_ObjectiveCondition SwapCondition)
{
     switch(ConditionType)
     {
        case 0 :  GetObjOwner().FailureConditions[Index]  = SwapCondition;   break;
        case 1 :  GetObjOwner().SuccessConditions[Index]  = SwapCondition;   break;
        case 2 :  GetObjOwner().OptionalConditions[Index] = SwapCondition;   break;
     }
}

defaultproperties
{
     PriorityBias=0.500000
     HUD_Screen=(Screen_ProgressStyle=HDS_TextOnly)
}
