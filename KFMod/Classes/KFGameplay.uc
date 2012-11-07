//=============================================================================
// KF Gameplay
//=============================================================================
class KFGameplay extends Mutator;

function ModifyPlayer(Pawn Other)
{
    local xPawn x;

    x = xPawn(Other);

    // KFTODO: maybe replace this?
    //if(x.health < x.HealthMax/2)
    // Spawn(class'XEffects.RedeemerExplosion',,, Location);

    Super.ModifyPlayer(Other);
}

defaultproperties
{
}
