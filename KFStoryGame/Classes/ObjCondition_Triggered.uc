/*
	--------------------------------------------------------------
	Condition_Triggered
	--------------------------------------------------------------

    This Condition is marked complete when its owning objective is
    the recipient of a trigger event

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ObjCondition_Triggered extends KF_ObjectiveCondition
hidecategories(Difficulty)
editinlinenew;


/* returns the percentage of completion for this condition */
function       float        GetCompletionPct()
{
     return float(bWasTriggered);
}

defaultproperties
{
     HUD_Screen=(Screen_ProgressStyle=HDS_TextOnly)
}
