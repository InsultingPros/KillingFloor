/*
	--------------------------------------------------------------

	Turns all KF_StoryNPCs in the map off or on.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ACTION_ToggleStoryNPCs extends ScriptedAction;

enum ENPCState
{
    Off,
    On
};

var () ENPCState DesiredState;

function bool InitActionFor(ScriptedController C)
{
    local KF_StoryNPC A;

    foreach C.AllActors(class 'KF_StoryNPC', A)
    {
        A.SetActive(bool(DesiredState));
    }

    return false;
}

defaultproperties
{
}
