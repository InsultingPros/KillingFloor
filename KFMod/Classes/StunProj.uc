//=============================================================================
// Stun Nade
//=============================================================================
class StunProj extends Grenade;

var() vector RotMag;            // how far to rot view
var() vector RotRate;           // how fast to rot view
var() float  RotTime;           // how much time to rot the instigator's view
var() vector OffsetMag;         // max view offset vertically
var() vector OffsetRate;        // how fast to offset view vertically
var() float  OffsetTime;        // how much time to offset view

#exec OBJ LOAD FILE=PatchSounds.uax

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local Controller        C;
    local PlayerController  LocalPlayer;

    BlowUp(HitLocation);
    PlaySound(sound'PatchSounds.StunNadeBoomSound',,100.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(class'KFmod.KFMiniExplosion',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }
    Destroy();
    
        // Shake nearby players screens

     LocalPlayer = Level.GetLocalPlayerController();
    if ( (LocalPlayer != None) && (VSize(Location - LocalPlayer.ViewTarget.Location) < DamageRadius) )       
        LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

    for ( C=Level.ControllerList; C!=None; C=C.NextController )
        if ( (PlayerController(C) != None) && (C != LocalPlayer)
            && (VSize(Location - PlayerController(C).ViewTarget.Location) < DamageRadius) )
            C.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
}

simulated function Destroyed()
{
    if ( Trail == None )
        Trail.mRegen = false; // stop the emitter from regenerating
    Super.Destroyed();
}


simulated function PostBeginPlay()
{
    local PlayerController PC;
    
    Super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer)
    {
        PC = Level.GetLocalPlayerController();
        if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5500 )
      }

    if ( Role == ROLE_Authority )
    {
        Velocity = Speed * Vector(Rotation);
        RandSpin(25000);
        bCanHitOwner = false;
        if (Instigator.HeadVolume.bWaterVolume)
        {
            bHitWater = true;
            Velocity = 0.6*Velocity;
        }
    }
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
   // if ( !Other.bWorldGeometry && (Other != Instigator || bCanHitOwner) )
    //{
      //  Explode(HitLocation, Normal(HitLocation-Other.Location));
   // }
}

defaultproperties
{
     RotMag=(X=100.000000,Y=100.000000,Z=100.000000)
     RotRate=(X=500.000000,Y=500.000000,Z=500.000000)
     RotTime=3.000000
     OffsetMag=(X=40.000000,Y=40.000000,Z=40.000000)
     OffsetRate=(X=500.000000,Y=500.000000,Z=500.000000)
     OffsetTime=3.000000
     DampenFactor=0.250000
     DampenFactorParallel=0.400000
     Speed=160.000000
     MaxSpeed=350.000000
     Damage=25.000000
     DamageRadius=350.000000
     MomentumTransfer=25000.000000
     MyDamageType=Class'KFMod.DamTypeStunNade'
     StaticMesh=StaticMesh'PatchStatics.StunProjectile'
     DrawScale=0.400000
     AmbientGlow=0
     bUnlit=False
}
