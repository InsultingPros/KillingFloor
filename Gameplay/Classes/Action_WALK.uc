class ACTION_Walk extends ScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	C.Pawn.ShouldCrouch(false);
	// if _RO_
	C.Pawn.ShouldProne(false);
	// endif _RO_
	C.Pawn.SetWalking(true);
	return false;
}

defaultproperties
{
     ActionString="walk"
     bValidForTrigger=False
}
