/*
	--------------------------------------------------------------
	Action_WinGame
	--------------------------------------------------------------

    This Action ends the match in victory, when Activated.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjAction_WinGame extends KF_ObjectiveAction
editinlinenew
HideCategories(KF_ObjectiveAction);

function ExecuteAction(Controller ActionInstigator)
{
    Super.ExecuteAction(ActionInstigator);
    GetObjOwner().StoryGI.EndGame(ActionInstigator.PlayerReplicationInfo,"WinAction");
}

defaultproperties
{
}
