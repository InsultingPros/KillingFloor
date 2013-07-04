/*
	--------------------------------------------------------------
	Action_GoToNextObjective
	--------------------------------------------------------------

    This Action changes the current objective to the next one
    in the sorted Objectives list defined in the Level Rules actor.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjAction_GoToNextObjective extends ObjAction_GoToObjective
hideCategories(KF_ObjectiveAction)
editinlinenew;

/* Offset to apply to ObjectiveIndex.  ie. We want to skip forward to the next,NEXT objective. (offset=1) */
var ()       int                   Offset;

/* if not null, Go to the next objective that has this tag */
var ()       name                  NextObjTag;

/* At Runtime query the gameinfo to figure out what the next objective is. Otherwise use the list
in the levelinfo */

function name GetTargetObj()
{
    local array<StoryObjectiveBase>  ObjectiveList;
    local int i,ObjIdx;

    if(GetObjOwner() != none && GetObjOwner().StoryGI != none)     // runtime.
    {
        ObjectiveList = GetObjOwner().StoryGI.SortedObjectives ;
        ObjIdx = GetObjOwner().StoryGI.CurrentObjectiveIdx;
    }

    if(NextObjTag == '')
    {
        return ObjectiveList[ ObjIdx + (1 + Offset) ].ObjectiveName ;
    }
    else
    {
        for(i = (ObjIdx + (1 + Offset)) ; i < ObjectiveList.length ; i ++)
        {
            if(ObjectiveList[i].tag == NextObjTag)
            {
                return ObjectiveList[i].ObjectiveName;
            }
        }
    }

    log("Warning - Could not find any objectives with tag : "@NextObjTag@" in the Sorted Objectives array."@self@" will fail. ");
    return '';
}

function StoryObjectiveBase GetNextEditorObj(StoryObjectiveBase Sender, array<StoryObjectiveBase> ObjList)
{
    local int i,idx,ObjIdx;
    local LevelInfo LI;
    local array<StoryObjectiveBase> SortedObjList;

    if(Sender == none)
    {
        return none;
    }

    LI = Sender.Level ;

    /* Build a list of the linear objectives in the map */
    SortedObjList.length = LI.StoryObjectives.length;

    for(i = 0 ; i < ObjList.length ; i ++)
    {
        for(idx = 0 ; idx < LI.StoryObjectives.length ; idx++)
        {
            if(ObjList[i].ObjectiveName == LI.StoryObjectives[idx])
            {
                SortedObjList[idx] = ObjList[i] ;
            }

            if(SortedObjList[idx] == Sender)
            {
                ObjIdx = idx;
            }
        }
    }

    ObjList = SortedObjList;

    if(NextObjTag == '')
    {
        return ObjList[ ObjIdx + (1 + Offset) ];
    }
    else
    {
        for(i = (ObjIdx + (1 + Offset)) ; i < ObjList.length ; i ++)
        {
            if(ObjList[i].tag == NextObjTag)
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
