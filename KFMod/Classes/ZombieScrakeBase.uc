// Chainsaw Zombie Monster for KF Invasion gametype
// He's not quite as speedy as the other Zombies, But his attacks are TRULY damaging.
class ZombieScrakeBase extends KFMonster;

#exec OBJ LOAD FILE=PlayerSounds.uax

var(Sounds) sound   SawAttackLoopSound; // THe sound for the saw revved up, looping
var(Sounds) sound   ChainSawOffSound;   //The sound of this zombie dieing without a head

var         bool    bCharging;          // Scrake charges when his health gets low
var()       float   AttackChargeRate;   // Ratio to increase scrake movement speed when charging and attacking

// Exhaust effects
var()	class<VehicleExhaustEffect>	ExhaustEffectClass; // Effect class for the exhaust emitter
var()	VehicleExhaustEffect 		ExhaustEffect;
var 		bool	bNoExhaustRespawn;

replication
{
	reliable if(Role == ROLE_Authority)
		bCharging;
}

//-------------------------------------------------------------------------------
// NOTE: All Code resides in the child class(this class was only created to
//         eliminate hitching caused by loading default properties during play)
//-------------------------------------------------------------------------------

defaultproperties
{
     SawAttackLoopSound=Sound'KF_BaseScrake.Chainsaw.Scrake_Chainsaw_Impale'
     ChainSawOffSound=SoundGroup'KF_ChainsawSnd.Chainsaw_Deselect'
     AttackChargeRate=2.500000
     ExhaustEffectClass=Class'KFMod.ChainsawExhaust'
     MeleeAnims(0)="SawZombieAttack1"
     MeleeAnims(1)="SawZombieAttack2"
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Talk'
     StunsRemaining=1
     BleedOutDuration=6.000000
     ZapThreshold=1.250000
     ZappedDamageMod=1.250000
     bHarpoonToBodyStuns=False
     DamageToMonsterScale=8.000000
     ZombieFlag=3
     MeleeDamage=20
     damageForce=-75000
     bFatAss=True
     KFRagdollName="Scrake_Trip"
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Chainsaw_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Jump'
     bMeleeStunImmune=True
     Intelligence=BRAINS_Mammal
     bUseExtendedCollision=True
     ColOffset=(Z=55.000000)
     ColRadius=29.000000
     ColHeight=18.000000
     SeveredArmAttachScale=1.100000
     SeveredLegAttachScale=1.100000
     PlayerCountHealthScale=0.500000
     PoundRageBumpDamScale=0.010000
     OnlineHeadshotOffset=(X=22.000000,Y=5.000000,Z=58.000000)
     OnlineHeadshotScale=1.500000
     HeadHealth=650.000000
     PlayerNumHeadHealthScale=0.300000
     MotionDetectorThreat=3.000000
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ScoringValue=75
     IdleHeavyAnim="SawZombieIdle"
     IdleRifleAnim="SawZombieIdle"
     MeleeRange=40.000000
     GroundSpeed=85.000000
     WaterSpeed=75.000000
     HealthMax=1000.000000
     Health=1000
     HeadHeight=2.200000
     MenuName="Scrake"
     MovementAnims(0)="SawZombieWalk"
     MovementAnims(1)="SawZombieWalk"
     MovementAnims(2)="SawZombieWalk"
     MovementAnims(3)="SawZombieWalk"
     WalkAnims(0)="SawZombieWalk"
     WalkAnims(1)="SawZombieWalk"
     WalkAnims(2)="SawZombieWalk"
     WalkAnims(3)="SawZombieWalk"
     IdleCrouchAnim="SawZombieIdle"
     IdleWeaponAnim="SawZombieIdle"
     IdleRestAnim="SawZombieIdle"
     AmbientSound=Sound'KF_BaseScrake.Chainsaw.Scrake_Chainsaw_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip.Scrake_Freak'
     DrawScale=1.050000
     PrePivot=(Z=3.000000)
     Skins(0)=Shader'KF_Specimens_Trip_T.scrake_FB'
     Skins(1)=TexPanner'KF_Specimens_Trip_T.scrake_saw_panner'
     SoundVolume=175
     SoundRadius=100.000000
     Mass=500.000000
     RotationRate=(Yaw=45000,Roll=0)
}
