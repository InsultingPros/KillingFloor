// Zombie Monster for KF Invasion gametype
class ZombieSirenBase extends KFMonster;

var () int ScreamRadius; // AOE for scream attack.

var () class <DamageType> ScreamDamageType;
var () int ScreamForce;

var(Shake)  rotator RotMag;            // how far to rot view
var(Shake)  float   RotRate;           // how fast to rot view
var(Shake)  vector  OffsetMag;         // max view offset vertically
var(Shake)  float   OffsetRate;        // how fast to offset view vertically
var(Shake)  float   ShakeTime;         // how long to shake for per scream
var(Shake)  float   ShakeFadeTime;     // how long after starting to shake to start fading out
var(Shake)  float	ShakeEffectScalar; // Overall scale for shake/blur effect
var(Shake)  float	MinShakeEffectScale;// The minimum that the shake effect drops off over distance
var(Shake)  float	ScreamBlurScale;   // How much motion blur to give from screams

var bool bAboutToDie;
var float DeathTimer;

//-------------------------------------------------------------------------------
// NOTE: All Code resides in the child class(this class was only created to
//         eliminate hitching caused by loading default properties during play)
//-------------------------------------------------------------------------------

defaultproperties
{
     ScreamRadius=700
     ScreamDamageType=Class'KFMod.SirenScreamDamage'
     ScreamForce=-150000
     RotMag=(Pitch=150,Yaw=150,Roll=150)
     RotRate=500.000000
     OffsetMag=(Y=5.000000,Z=1.000000)
     OffsetRate=500.000000
     ShakeTime=2.000000
     ShakeFadeTime=0.250000
     ShakeEffectScalar=1.000000
     MinShakeEffectScale=0.600000
     ScreamBlurScale=0.850000
     MeleeAnims(0)="Siren_Bite"
     MeleeAnims(1)="Siren_Bite2"
     MeleeAnims(2)="Siren_Bite"
     HitAnims(0)="HitReactionF"
     HitAnims(1)="HitReactionF"
     HitAnims(2)="HitReactionF"
     ZapThreshold=0.500000
     ZappedDamageMod=1.500000
     ZombieFlag=1
     MeleeDamage=13
     damageForce=5000
     KFRagdollName="Siren_Trip"
     ZombieDamType(0)=Class'KFMod.DamTypeSlashingAttack'
     ZombieDamType(1)=Class'KFMod.DamTypeSlashingAttack'
     ZombieDamType(2)=Class'KFMod.DamTypeSlashingAttack'
     ScreamDamage=8
     CrispUpThreshhold=7
     bCanDistanceAttackDoors=True
     bUseExtendedCollision=True
     ColOffset=(Z=48.000000)
     ColRadius=25.000000
     ColHeight=5.000000
     ExtCollAttachBoneName="Collision_Attach"
     SeveredLegAttachScale=0.700000
     PlayerCountHealthScale=0.100000
     OnlineHeadshotOffset=(X=6.000000,Z=41.000000)
     OnlineHeadshotScale=1.200000
     HeadHealth=200.000000
     PlayerNumHeadHealthScale=0.050000
     MotionDetectorThreat=2.000000
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Challenge'
     ScoringValue=25
     SoundGroupClass=Class'KFMod.KFFemaleZombieSounds'
     IdleHeavyAnim="Siren_Idle"
     IdleRifleAnim="Siren_Idle"
     MeleeRange=45.000000
     GroundSpeed=100.000000
     WaterSpeed=80.000000
     HealthMax=300.000000
     Health=300
     HeadHeight=1.000000
     HeadScale=1.000000
     MenuName="Siren"
     MovementAnims(0)="Siren_Walk"
     MovementAnims(1)="Siren_Walk"
     MovementAnims(2)="Siren_Walk"
     MovementAnims(3)="Siren_Walk"
     WalkAnims(0)="Siren_Walk"
     WalkAnims(1)="Siren_Walk"
     WalkAnims(2)="Siren_Walk"
     WalkAnims(3)="Siren_Walk"
     IdleCrouchAnim="Siren_Idle"
     IdleWeaponAnim="Siren_Idle"
     IdleRestAnim="Siren_Idle"
     DrawScale=1.050000
     PrePivot=(Z=3.000000)
     RotationRate=(Yaw=45000,Roll=0)
}
