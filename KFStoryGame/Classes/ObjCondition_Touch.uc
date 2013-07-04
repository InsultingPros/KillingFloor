/*
	--------------------------------------------------------------
	Condition_Touch
	--------------------------------------------------------------

    This Condition is marked complete when a player encroaches the
    collision cylinder of its owning Objective actor.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjCondition_Touch extends KF_ObjectiveCondition
hidecategories(Difficulty)
editinlinenew;

/* returns the percentage of completion for this condition */
function       float        GetCompletionPct()
{
     return float(GetObjOwner().bWasTouched) ;
}

defaultproperties
{
}
