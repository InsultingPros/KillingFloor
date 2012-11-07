class KFBreakableSM extends StaticMeshActor;
/*

var () StaticMesh SmashedMesh;
var () int Health,ExplodeDamage,ExplodeRadius,ExplodeForce;
var () bool bExplosiveAffectedOnly;
var () class <DamageType> ExplodeDamageType;
var ()  class<Projector> ExplosionDecal;
var ()  sound    ExplosionSound;
var () class <emitter> ExplosionEffect;

var() vector RotMag;            // how far to rot view
var() vector RotRate;           // how fast to rot view
var() float  RotTime;           // how much time to rot the instigator's view
var() vector OffsetMag;         // max view offset vertically
var() vector OffsetRate;        // how fast to offset view vertically
var() float  OffsetTime;        // how much time to offset view

var bool bPlayedSmash;

replication
{
  reliable if ( bNetInitial && (Role==ROLE_Authority) )
    SmashedMesh;
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
 local Controller        C;
 local PlayerController  LocalPlayer;


if (bExplosiveAffectedOnly && DamageType != class 'DamTypeFrag')
 return;

 if (Damage >= Health && Health > 0 )
 {
  SetStaticMesh(SmashedMesh);
  log("KFBreakableSM SM = "$StaticMesh);
  HurtRadius(ExplodeDamage ,ExplodeRadius, ExplodeDamageType, ExplodeForce, Location) ;
  
  // Shake nearby players screens

     LocalPlayer = Level.GetLocalPlayerController();
    if ( (LocalPlayer != None) && (VSize(Location - LocalPlayer.ViewTarget.Location) < (ExplodeRadius * 2 )) )
        LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

    for ( C=Level.ControllerList; C!=None; C=C.NextController )
        if ( (PlayerController(C) != None) && (C != LocalPlayer)
            && (VSize(Location - PlayerController(C).ViewTarget.Location) < (ExplodeRadius * 2 )) )
            C.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

  if (Level.NetMode == NM_ListenServer || Level.NetMode == NM_StandAlone)
  {
    SpawnEffects(HitLocation, vect(0,0,0));
  }
 }
 //else
  Health -= Damage;
}


simulated function SpawnEffects( vector HitLocation, vector HitNormal )
{
    local PlayerController PC;

    PlaySound (ExplosionSound,,3*TransientSoundVolume);

    //log("KFBreakableSM EffectIsRelevant(Location,false) = "$EffectIsRelevant(Location,false));

    if ( EffectIsRelevant(Location,false) )
    {
        PC = Level.GetLocalPlayerController();
        if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 3000 )
            spawn(class'FlakExplosion',,,HitLocation + HitNormal*16 );
        spawn(class'FlashExplosion',,,HitLocation + HitNormal*16 );
        spawn(ExplosionEffect,,,HitLocation + HitNormal*16, rotator(HitNormal) );
        if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
            Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }
}

simulated function PostNetReceive()
{

	log("POSTNETRECIEVE! - StaticMesh = "$StaticMesh);
	log("SmashedMesh = "$SmashedMesh);
	log("bPlayedSmash = "$bPlayedSmash);
	log("StaticMesh==SmashedMesh && !bPlayedSmash = "$(StaticMesh==SmashedMesh && !bPlayedSmash) );

    if ( StaticMesh==SmashedMesh && !bPlayedSmash )
	{
	  //log("BOOM!");
      bPlayedSmash = true;
	  SpawnEffects(Location, vect(0,0,0));
    }
}
  */



/*
defaultproperties
{

 ExplodeForce = 50000
 ExplodeRadius = 200
 ExplodeDamage = 50
 Health = 100
 StaticMesh = StaticMesh'KillingFloorStatics.LookTargetMoverDummy'


 bStatic = false;
 bStasis = false;
 ExplodeDamageType = class 'Gameplay.Burned'
 //bWorldGeometry=False
 bAcceptsProjectors = True
 ExplosionDecal=class'RocketMark'
 ExplosionSound = Sound'WeaponSounds.BExplosion1'
 ExplosionEffect = class 'KFMod.KFVehicleExplosion'
 bNetNotify=True
 
 RotMag=(X=100.000000,Y=100.000000,Z=100.000000)
 RotRate=(X=500.000000,Y=500.000000,Z=500.000000)
 RotTime=3.000000
 OffsetMag=(X=40.000000,Y=40.000000,Z=40.000000)
 OffsetRate=(X=500.000000,Y=500.000000,Z=500.000000)
 OffsetTime=3.000000

}
*/

defaultproperties
{
}
