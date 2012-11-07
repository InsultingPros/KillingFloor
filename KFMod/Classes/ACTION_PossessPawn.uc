//=============================================================================
// ACTION_PossessPawn.
// Possess the Pawn with the PawnTag.  Destroy any previous MonsterController.
// by SuperApe -- Dec 2005
//=============================================================================
class ACTION_PossessPawn extends ScriptedAction;
 
var()        name   PawnTag;
var            bool   bPawnExists;
 
function bool InitActionFor( ScriptedController C )
{
	local Pawn P;
	local MonsterController MC;
 
	bPawnExists = false;
	forEach C.DynamicActors( class'Pawn', P, PawnTag )
	{
		bPawnExists = true;
		if ( P.Controller.IsA('MonsterController') )
			MC = MonsterController( P.Controller );      
		P.Controller.Unpossess();
 
		if ( P.Health > 0 )
		{
			C.Possess( P );
			P.Controller = C;
			P.AIScriptTag = C.Tag;
		}
		else P.AIScriptTag = '';
		if ( MC != None )
			MC.Destroy();
	}
	if ( !bPawnExists )
		Warn("No Pawn with tag "$PawnTag$" exists!");
	return false;
}

defaultproperties
{
}
