//=============================================================================
// ACTION_IfMonsterIsHurt.
// Conditional on Pawn.Health < HealthThreshold
// by SuperApe -- Dec 2005
//=============================================================================
class ACTION_IfMonsterIsHurt extends ScriptedAction;
 
var()        int            HealthThreshold;
 
function ProceedToNextAction( ScriptedController C )
{
        if ( !C.Pawn.IsA('Monster') )
                ProceedToSectionEnd( C );
 
        C.ActionNum += 1;
        if ( C.Pawn.Health > HealthThreshold )
                ProceedToSectionEnd( C );
}
 
function bool StartsSection()
{
        return true;
}

defaultproperties
{
}
