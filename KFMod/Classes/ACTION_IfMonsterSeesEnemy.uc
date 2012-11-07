//=============================================================================
// ACTION_IfMonsterSeesEnemy.
// Conditional on MonsterController.bEnemyIsVisible
// by SuperApe -- Dec 2005
//=============================================================================
class ACTION_IfMonsterSeesEnemy extends ScriptedAction;
 
function ProceedToNextAction( ScriptedController C )
{
        if ( !C.Pawn.IsA('Monster') || MonsterController( C.Pawn.Controller ) == None )
                ProceedToSectionEnd( C );
 
        C.ActionNum += 1;
        if ( !MonsterController(C.Pawn.Controller).bEnemyIsVisible )
                ProceedToSectionEnd( C );
}
 
function bool StartsSection()
{
        return true;
}

defaultproperties
{
}
