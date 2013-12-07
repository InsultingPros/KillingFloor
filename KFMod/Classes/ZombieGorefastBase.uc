// Zombie Monster for KF Invasion gametype
// He's speedy, and swings with a Single enlongated arm, affording him slightly more range
class ZombieGoreFastBase extends KFMonster;

#exec OBJ LOAD FILE=PlayerSounds.uax

var bool bRunning;
var float RunAttackTimeout;

replication
{
	reliable if(Role == ROLE_Authority)
		bRunning;
}

//-------------------------------------------------------------------------------
// NOTE: All Code resides in the child class(this class was only created to
//         eliminate hitching caused by loading default properties during play)
//-------------------------------------------------------------------------------

defaultproperties
{
     MeleeAnims(0)="GoreAttack1"
     MeleeAnims(1)="GoreAttack2"
     MeleeAnims(2)="GoreAttack1"
     bCannibal=True
     MeleeDamage=15
     damageForce=5000
     KFRagdollName="GoreFast_Trip"
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.GoreFast.Gorefast_HitPlayer'
     CrispUpThreshhold=8
     bUseExtendedCollision=True
     ColOffset=(Z=52.000000)
     ColRadius=25.000000
     ColHeight=10.000000
     ExtCollAttachBoneName="Collision_Attach"
     SeveredArmAttachScale=0.900000
     SeveredLegAttachScale=0.900000
     PlayerCountHealthScale=0.150000
     OnlineHeadshotOffset=(X=5.000000,Z=53.000000)
     OnlineHeadshotScale=1.500000
     MotionDetectorThreat=0.500000
     ScoringValue=12
     IdleHeavyAnim="GoreIdle"
     IdleRifleAnim="GoreIdle"
     MeleeRange=30.000000
     GroundSpeed=120.000000
     WaterSpeed=140.000000
     HealthMax=250.000000
     Health=250
     HeadHeight=2.500000
     HeadScale=1.500000
     MenuName="Gorefast"
     MovementAnims(0)="GoreWalk"
     WalkAnims(0)="GoreWalk"
     WalkAnims(1)="GoreWalk"
     WalkAnims(2)="GoreWalk"
     WalkAnims(3)="GoreWalk"
     IdleCrouchAnim="GoreIdle"
     IdleWeaponAnim="GoreIdle"
     IdleRestAnim="GoreIdle"
     DrawScale=1.200000
     PrePivot=(Z=10.000000)
     Mass=350.000000
     RotationRate=(Yaw=45000,Roll=0)
}
