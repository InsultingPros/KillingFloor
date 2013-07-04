/*
	--------------------------------------------------------------
	KF_ObjectiveAction
	--------------------------------------------------------------

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class KF_ObjectiveAction extends BaseObjectiveAction
hidecategories(Object);

/* Reference to the Objective that this action belongs to */
var          private                     KF_StoryObjective           ObjOwner;

/* Is this action currently being processed ? */
var          bool                        bActive;

function bool IsValidActionFor(KF_StoryObjective Obj)
{
    return true;
}

function KF_StoryObjective             GetObjOwner()
{
    return ObjOwner;
}

function SetObjOwner(Actor NewOwner)
{
    ObjOwner = KF_StoryObjective(NewOwner);
}

function ActionActivated(pawn ActivatingPlayer)
{
     bActive = true;
}
function ActionDeActivated()
{
     Reset();
}

function Reset()
{
    bActive = false;
}

defaultproperties
{
}
