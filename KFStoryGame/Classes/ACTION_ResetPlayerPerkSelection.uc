/*
	--------------------------------------------------------------
	ACTION_ResetPlayerPerkSelection
	--------------------------------------------------------------

	Force allows players to be able to change their perks.

	Author :  Alex Quick

	--------------------------------------------------------------
*/

class ACTION_ResetPlayerPerkSelection extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	local Controller Controller;
	local KFPC KFController;

	for ( Controller = C.Level.ControllerList; Controller != none; Controller = Controller.NextController )
	{
        KFController = KFPC(Controller);
        if(KFController != none)
        {
            KFController.bChangedVeterancyThisWave = false;
        }
	}

    return false;
}

defaultproperties
{
}
