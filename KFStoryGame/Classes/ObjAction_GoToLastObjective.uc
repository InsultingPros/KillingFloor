//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ObjAction_GoToLastObjective extends ObjAction_GoToObjective
hideCategories(KF_ObjectiveAction)
editinlinenew;

function name GetTargetObj()
{
    /* Last objective only returns anything meaningful at runtime */
    if(GetObjOwner() != none && GetObjOwner().StoryGI != none)
    {
        return GetObjOwner().StoryGI.LastObjective.ObjectiveName ;
    }

    return '';
}

defaultproperties
{
}
