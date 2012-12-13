// Zombie Monster for KF Invasion gametype
class ZombieBloatBase extends KFMonster;

#exec OBJ LOAD FILE=PlayerSounds.uax
#exec OBJ LOAD FILE=KF_EnemiesFinalSnd.uax

var BileJet BloatJet;
var bool bPlayBileSplash;
var bool bMovingPukeAttack;
var float RunAttackTimeout;

//-------------------------------------------------------------------------------
// NOTE: All Code resides in the child class(this class was only created to
//         eliminate hitching caused by loading default properties during play)
//-------------------------------------------------------------------------------

defaultproperties
{
     MeleeAnims(0)="BloatChop2"
     MeleeAnims(1)="BloatChop2"
     MeleeAnims(2)="BloatChop2"
     BleedOutDuration=6.000000
     ZapThreshold=0.500000
     ZappedDamageMod=1.500000
     ZombieFlag=1
     MeleeDamage=14
     damageForce=70000
     bFatAss=True
     KFRagdollName="Bloat_Trip"
     PuntAnim="BloatPunt"
     Intelligence=BRAINS_Stupid
     bCanDistanceAttackDoors=True
     bUseExtendedCollision=True
     ColOffset=(Z=60.000000)
     ColRadius=27.000000
     ColHeight=22.000000
     SeveredArmAttachScale=1.100000
     SeveredLegAttachScale=1.300000
     SeveredHeadAttachScale=1.700000
     PlayerCountHealthScale=0.250000
     OnlineHeadshotOffset=(X=5.000000,Z=70.000000)
     OnlineHeadshotScale=1.500000
     AmmunitionClass=Class'KFMod.BZombieAmmo'
     ScoringValue=17
     IdleHeavyAnim="BloatIdle"
     IdleRifleAnim="BloatIdle"
     MeleeRange=30.000000
     GroundSpeed=75.000000
     WaterSpeed=102.000000
     HealthMax=525.000000
     Health=525
     HeadHeight=2.500000
     HeadScale=1.500000
     AmbientSoundScaling=8.000000
     MenuName="Bloat"
     MovementAnims(0)="WalkBloat"
     MovementAnims(1)="WalkBloat"
     WalkAnims(0)="WalkBloat"
     WalkAnims(1)="WalkBloat"
     WalkAnims(2)="WalkBloat"
     WalkAnims(3)="WalkBloat"
     IdleCrouchAnim="BloatIdle"
     IdleWeaponAnim="BloatIdle"
     IdleRestAnim="BloatIdle"
     DrawScale=1.075000
     PrePivot=(Z=5.000000)
     SoundVolume=200
     Mass=400.000000
     RotationRate=(Yaw=45000,Roll=0)
}
