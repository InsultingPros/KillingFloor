/*
	--------------------------------------------------------------
	BaseObjectiveAction
	--------------------------------------------------------------

	Base Class for things that occur after an objective is completed

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class BaseObjectiveAction extends Object
native;

var                            byte                        ActionType;                 // 0 = failure, 1 = success

var (KF_ObjectiveAction)       const name                  ObjectiveName;

/* interfaces */
function SetObjOwner(Actor NewOwner){}
function ActionActivated(pawn ActivatingPlayer){}
function ActionDeActivated(){}
function StoryObjectiveBase GetNextEditorObj(StoryObjectiveBase Sender, array<StoryObjectiveBase> ObjList){}
function name GetTargetObj(){}
function ExecuteAction(Controller ActionInstigator){}

defaultproperties
{
}
