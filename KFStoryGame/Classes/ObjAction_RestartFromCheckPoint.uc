/*
	--------------------------------------------------------------
	Action_RestartFromCheckPoint
	--------------------------------------------------------------

    This Action forces players to respawn from the last activated checkpoint

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjAction_RestartFromCheckPoint extends KF_ObjectiveAction
editinlinenew
HideCategories(KF_ObjectiveAction);

function ExecuteAction(Controller ActionInstigator)
{
    Super.ExecuteAction(ActionInstigator);
    GetObjOwner().StoryGI.RestartEveryone() ;
}

defaultproperties
{
}
