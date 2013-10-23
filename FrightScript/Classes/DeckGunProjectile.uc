// The projectiles fired by the Deck Gun in the 2013 Halloween map.

class DeckGunProjectile extends ROBallisticProjectile;

var Emitter Trail;

var Sound ExplosionSound;
var     float       ExplosionSoundVolume;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if(Level.NetMode != NM_DedicatedServer)
    {
        Trail = Spawn(class 'DeckGunProjectile_Trail');
        Trail.LifeSpan = LifeSpan;
        Trail.SetBase(self);
    }
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local ProjectedDecal VomitDecal ;

    if(Trail != none)
    {
        Trail.Kill();
    }

    if(Level.NetMode != NM_DedicatedServer)
    {
   	    Spawn(class'FrightScript.DeckGunProjectile_Explosion');
    }

    if(Role == Role_Authority && ExplosionSound != none)
    {
        PlaySound(ExplosionSound,SlOT_Misc,ExplosionSoundVolume,true,TransientSoundRadius,,false);
    }

    VomitDecal = Spawn(class'KFMod.VomitDecalGlow',,,, rotator(-HitNormal));
//    VomitDecal = Spawn(class'KFMod.VomitDecalGlow',,,, rotator(-HitNormal));
//    VomitDecal = Spawn(class'KFMod.VomitDecalGlow',,,, rotator(-HitNormal));

    bHidden = true;

    BlowUp(HitLocation);
    Super.Explode(HitLocation,HitNormal);
}


simulated function Tick(float DeltaTime)
{
    SetRotation(Rotator(Normal(Velocity)));
}

simulated event Landed( vector HitNormal )
{
    Super.Landed(HitNormal);
    Explode(Location,HitNormal);
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
    if(InstigatedBy != none && InstigatedBy.GetTeamNum() == 0)
    {
        Explode(HitLocation, vect(0,0,1));
    }
}

defaultproperties
{
     ExplosionSound=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_DeathPop'
     ExplosionSoundVolume=2.000000
     AmbientVolumeScale=3.500000
     bTrueBallistics=False
     bInitialAcceleration=False
     MaxSpeed=0.000000
     Damage=5.000000
     DamageRadius=320.000000
     MyDamageType=Class'KFMod.DamTypeBileDeckGun'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'kf_gore_trip_sm.gibbs.bloat_explode'
     Physics=PHYS_Falling
     AmbientSound=Sound'Vehicle_Weapons.Misc.projectile_whistle01'
     Skins(0)=Shader'kf_fx_trip_t.Gore.Intestines_Glow_SHDR'
     SoundVolume=255
     SoundRadius=250.000000
     CollisionRadius=30.000000
     CollisionHeight=30.000000
     bProjTarget=True
}
