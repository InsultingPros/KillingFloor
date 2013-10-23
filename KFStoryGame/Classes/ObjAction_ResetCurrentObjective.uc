/*
	--------------------------------------------------------------
	Action_ResetCurrentObjective
	--------------------------------------------------------------

    This Action resets the currently active objective to the state it was in when it was first activated.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjAction_ResetCurrentObjective extends KF_ObjectiveAction
editinlinenew
HideCategories(KF_ObjectiveAction);

function ExecuteAction(Controller ActionInstigator)
{
    Super.ExecuteAction(ActionInstigator);

    if(GetObjOwner() != none)
    {
        GetObjOwner().StoryGI.CurrentObjective.Reset();
        GetObjOwner().StoryGI.CurrentObjective.Notify_ConditionsActivated(ActionInstigator.Pawn);
    }
}

defaultproperties
{
}
