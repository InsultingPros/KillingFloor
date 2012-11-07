//=============================================================================
// ACTION_IfMonsterHasEnemy.
// Conditional on Pawn.Controller.Enemy != None
// by SuperApe -- Dec 2005
//=============================================================================
class ACTION_IfMonsterHasEnemy extends ScriptedAction;
 
function ProceedToNextAction( ScriptedController C )
{
        if ( !C.Pawn.IsA('Monster') )
                ProceedToSectionEnd( C );
 
        C.ActionNum += 1;
        if ( C.Pawn.Controller.Enemy == None )
                ProceedToSectionEnd( C );
}
 
function bool StartsSection()
{
        return true;
}

defaultproperties
{
}
