/*
	--------------------------------------------------------------
	Action_LoseGame
	--------------------------------------------------------------

    This Action ends the match in defeat, when Activated.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjAction_LoseGame extends KF_ObjectiveAction
editinlinenew
HideCategories(KF_ObjectiveAction);

function ExecuteAction(Controller ActionInstigator)
{
    Super.ExecuteAction(ActionInstigator);
    GetObjOwner().StoryGI.EndGame(ActionInstigator.PlayerReplicationinfo, "LoseAction") ;
}

defaultproperties
{
}
