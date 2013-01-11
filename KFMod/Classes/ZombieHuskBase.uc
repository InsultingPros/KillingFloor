//=============================================================================
// ZombieHusk
//=============================================================================
// Husk burned up fire projectile launching zed pawn class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class ZombieHuskBase extends KFMonster;

var     float   NextFireProjectileTime; // Track when we will fire again
var()   float   ProjectileFireInterval; // How often to fire the fire projectile
var()   float   BurnDamageScale;        // How much to reduce fire damage for the Husk

//-------------------------------------------------------------------------------
// NOTE: All Code resides in the child class(this class was only created to
//         eliminate hitching caused by loading default properties during play)
//-------------------------------------------------------------------------------

defaultproperties
{
     ProjectileFireInterval=5.500000
     BurnDamageScale=0.250000
     MeleeAnims(0)="Strike"
     MeleeAnims(1)="Strike"
     MeleeAnims(2)="Strike"
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Talk'
     BleedOutDuration=6.000000
     ZapThreshold=0.750000
     ZombieFlag=1
     MeleeDamage=15
     damageForce=70000
     bFatAss=True
     KFRagdollName="Burns_Trip"
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Jump'
     Intelligence=BRAINS_Mammal
     bCanDistanceAttackDoors=True
     bUseExtendedCollision=True
     ColOffset=(Z=36.000000)
     ColRadius=30.000000
     ColHeight=33.000000
     SeveredArmAttachScale=0.900000
     SeveredLegAttachScale=0.900000
     SeveredHeadAttachScale=0.900000
     PlayerCountHealthScale=0.100000
     OnlineHeadshotOffset=(X=20.000000,Z=55.000000)
     HeadHealth=200.000000
     PlayerNumHeadHealthScale=0.050000
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Challenge'
     AmmunitionClass=Class'KFMod.BZombieAmmo'
     ScoringValue=17
     IdleHeavyAnim="Idle"
     IdleRifleAnim="Idle"
     MeleeRange=30.000000
     GroundSpeed=115.000000
     WaterSpeed=102.000000
     HealthMax=600.000000
     Health=600
     HeadHeight=1.000000
     HeadScale=1.500000
     AmbientSoundScaling=8.000000
     MenuName="Husk"
     MovementAnims(0)="WalkF"
     MovementAnims(1)="WalkB"
     MovementAnims(2)="WalkL"
     MovementAnims(3)="WalkR"
     WalkAnims(1)="WalkB"
     WalkAnims(2)="WalkL"
     WalkAnims(3)="WalkR"
     IdleCrouchAnim="Idle"
     IdleWeaponAnim="Idle"
     IdleRestAnim="Idle"
     AmbientSound=Sound'KF_BaseHusk.Husk_IdleLoop'
     Mesh=SkeletalMesh'KF_Freaks2_Trip.Burns_Freak'
     DrawScale=1.400000
     PrePivot=(Z=22.000000)
     Skins(0)=Texture'KF_Specimens_Trip_T_Two.burns.burns_tatters'
     Skins(1)=Shader'KF_Specimens_Trip_T_Two.burns.burns_shdr'
     SoundVolume=200
     Mass=400.000000
     RotationRate=(Yaw=45000,Roll=0)
}
