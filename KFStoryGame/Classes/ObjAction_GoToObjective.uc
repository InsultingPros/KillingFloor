/*
	--------------------------------------------------------------
	Action_GoToObjective
	--------------------------------------------------------------

    This Action changes the current objective to the one specified

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjAction_GoToObjective extends KF_ObjectiveAction
editinlinenew;

function ExecuteAction(Controller ActionInstigator)
{
    Super.ExecuteAction(ActionInstigator);
    GetObjOwner().StoryGI.SetActiveObjective(GetObjOwner().StoryGI.FindObjectiveNamed(GetTargetObj()),ActionInstigator.Pawn)   ;
}

function bool IsValidActionFor(KF_StoryObjective Obj)
{
    local KF_StoryObjective TargetObj;

    TargetObj = Obj.StoryGI.FindObjectiveNamed(GetTargetObj());
    if(TargetObj != none)
    {
        return TargetObj.IsValidForActivation();
    }

    return false;
}

function name GetTargetObj()
{
    return ObjectiveName;
}


function StoryObjectiveBase GetNextEditorObj(StoryObjectiveBase Sender, array<StoryObjectiveBase> ObjList)
{
    local int i;

    if(ObjectiveName != '')
    {
        for(i = 0 ; i < ObjList.length ; i ++)
        {
            if(ObjList[i].ObjectiveName == ObjectiveName)
            {
                return ObjList[i];
            }
        }
    }

    return none;
}

defaultproperties
{
}
