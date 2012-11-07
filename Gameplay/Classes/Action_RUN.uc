class ACTION_Run extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	C.Pawn.ShouldCrouch(false);
	// if _RO_
	C.Pawn.ShouldProne(false);
	// endif _RO_
	C.Pawn.SetWalking(false);
	return false;
}

defaultproperties
{
     ActionString="Run"
     bValidForTrigger=False
}
