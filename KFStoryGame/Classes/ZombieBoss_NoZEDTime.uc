// Patriarch used in the 2014 KFO map.  Killing Him won't cause ZED time or any other End of match effects.

class ZombieBoss_NoZEDTime extends ZombieBoss_STANDARD;

var bool SpawnedEyeBall;

var name EyeBallBoneName;

function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
    // Don't take damage from other patriarchs.
    if(InstigatedBy != none && InstigatedBy.IsA('ZombieBoss'))
    {
        return;
    }

    Super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,DamageType,HitIndex);
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local ZombieBoss Patriarch;
    local vector EyeSpawnLocation;
    local Pickup_PatriarchEyeball EyeBall;

    super(KFMonster).Died(Killer,damageType,HitLocation);

    // If there's another patriarch alive somewhere, then don't do the end of match stuff.

    foreach DynamicActors(class 'ZombieBoss', Patriarch)
    {
        if(Patriarch != none && Patriarch != self && Patriarch.Health > 0)
        {
            return;
        }
    }

    // Last Patriarch died!!  Drama ! and Eyeballs! Woo!
    if(KFGameType(Level.Game) != none)
    {
        KFGameType(Level.Game).DramaticEvent(1.f,4.f);
    }

    // Spawn an eyeball!
    if(!SpawnedEyeBall)
    {
        EyeSpawnLocation = Location + (vect(0,0,1) * CollisionHeight/2);
        SetBoneScale(0,0.01,EyeBallBoneName);

        SpawnedEyeBall = true;
        EyeBall = Spawn(class 'Pickup_PatriarchEyeball',self,'PatriarchEyeBallTag',EyeSpawnLocation,Rotation);
        if(EyeBall != none)
        {
            EyeBall.Velocity = Normal(EyeSpawnLocation - HitLocation) * 100.f + vect(0,0,1) * 20.f ;
        }
    }

}

defaultproperties
{
     EyeBallBoneName="CHR_HeadBone_eyeball6"
}
