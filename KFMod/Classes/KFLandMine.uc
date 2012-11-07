// Landmine which destroys itself on exploding...

class KFLandMine extends Landmine;

function PostTouch(Actor Other)
{
    local Pawn P;

    P = Pawn(Other);
    if (P != None)
    {
        PlaySound(BlowupSound,,3.0*TransientSoundVolume);
        spawn(BlowupEffect,,,P.Location - P.CollisionHeight * vect(0,0,1));
        P.AddVelocity(ChuckVelocity);
        P.Died(None, DamageType, P.Location);
    }

    Destroy();
}

defaultproperties
{
}
