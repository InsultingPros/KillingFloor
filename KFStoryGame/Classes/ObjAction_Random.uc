/*
	--------------------------------------------------------------
	Action_Random
	--------------------------------------------------------------

    This Action serves as a container for any number of other Actions.
    when initalized, it picks one at random and activates it.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjAction_Random extends KF_ObjectiveAction
editinlinenew
HideCategories(KF_ObjectiveAction);

struct SRandomAction
{
     var             () editinlineuse             KF_ObjectiveAction      Action;

     var             ()                           int                     Priority;
};


var (Actions)                                     float                   PriorityBias;

var (Actions)          editinlineuse              array<SRandomAction>    RandomActions;


var                 int                           RandIdx;


function ExecuteAction(Controller ActionInstigator)
{
     Super.ExecuteAction(ActionInstigator);
     AssignRandomAction(ActionInstigator);
}

function Reset()
{
     super.Reset();
     SwapAction(self);
}


function AssignRandomAction(Controller ActionInstigator)
{
     local float HighestRating;
     local float PriorityVal;
	 local int				BestIdx;
	 local array<float>		Ratings;
	 local int i,idx;

	 HighestRating = -1;
	 BestIdx       = -1;

	 for(i = 0 ; i < RandomActions.length ; i ++)
	 {
		 PriorityVal = RandomActions[i].Priority ;
		 Ratings[i] = RandRange( FMin(Ratings[idx] * PriorityBias,Ratings[idx]) , PriorityVal  ) ;
	 }

	 for(idx = 0 ; idx < Ratings.length ; idx ++)
	 {
		 if(Ratings[idx] > highestRating &&
         RandomActions[idx].Action.IsValidActionFor(GetObjOwner()) )
		 {
			 BestIdx = idx;
			 HighestRating = Ratings[idx] ;
		 }
	 }

	 if(BestIdx < 0 || BestIdx >= RandomActions.length)
	 {
         log("Warning -  Cannot find a valid action for : "@self@" Random action will fail. ",'Story_Debug');
	 }

     RandIdx = BestIdx;
     RandomActions[RandIdx].Action.ActionType = ActionType;
     RandomActions[RandIdx].Action.SetObjOwner(GetObjOwner());
     SwapAction(RandomActions[RandIdx].Action) ;
     RandomActions[RandIdx].Action.ExecuteAction(ActionInstigator);
}

function SwapAction(KF_ObjectiveAction SwapAction)
{
     switch(ActionType)
     {
        case 0 :  GetObjOwner().FailureAction = SwapAction;   break;
        case 1 :  GetObjOwner().SuccessAction = SwapAction;   break;
     }
}

defaultproperties
{
     PriorityBias=0.500000
}
