// Zombie Monster for KF Invasion gametype
class ZombieStalkerBase extends KFMonster
    abstract;

#exec OBJ LOAD FILE=PlayerSounds.uax
#exec OBJ LOAD FILE=KFX.utx
#exec OBJ LOAD FILE=KF_BaseStalker.uax

var float NextCheckTime;
var KFHumanPawn LocalKFHumanPawn;
var float LastUncloakTime;

//-------------------------------------------------------------------------------
// NOTE: All Code resides in the child class(this class was only created to
//         eliminate hitching caused by loading default properties during play)
//-------------------------------------------------------------------------------

defaultproperties
{
     MeleeAnims(0)="StalkerSpinAttack"
     MeleeAnims(1)="StalkerAttack1"
     MeleeAnims(2)="JumpAttack"
     MeleeDamage=9
     damageForce=5000
     KFRagdollName="Stalker_Trip"
     ZombieDamType(0)=Class'KFMod.DamTypeSlashingAttack'
     ZombieDamType(1)=Class'KFMod.DamTypeSlashingAttack'
     ZombieDamType(2)=Class'KFMod.DamTypeSlashingAttack'
     CrispUpThreshhold=10
     PuntAnim="ClotPunt"
     SeveredArmAttachScale=0.800000
     SeveredLegAttachScale=0.700000
     OnlineHeadshotOffset=(X=18.000000,Z=33.000000)
     OnlineHeadshotScale=1.200000
     MotionDetectorThreat=0.250000
     ScoringValue=15
     SoundGroupClass=Class'KFMod.KFFemaleZombieSounds'
     IdleHeavyAnim="StalkerIdle"
     IdleRifleAnim="StalkerIdle"
     MeleeRange=30.000000
     GroundSpeed=200.000000
     WaterSpeed=180.000000
     JumpZ=350.000000
     Health=100
     HeadHeight=2.500000
     MenuName="Stalker"
     MovementAnims(0)="ZombieRun"
     MovementAnims(1)="ZombieRun"
     MovementAnims(2)="ZombieRun"
     MovementAnims(3)="ZombieRun"
     WalkAnims(0)="ZombieRun"
     WalkAnims(1)="ZombieRun"
     WalkAnims(2)="ZombieRun"
     WalkAnims(3)="ZombieRun"
     IdleCrouchAnim="StalkerIdle"
     IdleWeaponAnim="StalkerIdle"
     IdleRestAnim="StalkerIdle"
     DrawScale=1.100000
     PrePivot=(Z=5.000000)
     RotationRate=(Yaw=45000,Roll=0)
}
