//-----------------------------------------------------------
// Circus Clot for the summer sideshow event
//-----------------------------------------------------------

class ZombieClot_CIRCUS extends ZombieClot;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_CIRCUS.uax

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_CIRCUS_T.clot_CIRCUS.clot_CIRCUS_CMB');
 }

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.clot.Clot_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.clot.Clot_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.clot.Clot_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmClot_CIRCUS'
     DetachedLegClass=Class'KFChar.SeveredLegClot_CIRCUS'
     DetachedHeadClass=Class'KFChar.SeveredHeadClot_CIRCUS'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.clot.Clot_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.clot.Clot_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.clot.Clot_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.clot.Clot_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.clot.Clot_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.clot.Clot_Challenge'
     MenuName="Circus Clot"
     AmbientSound=Sound'KF_BaseClot_CIRCUS.Clot_Idle1Loop'
     Mesh=SkeletalMesh'KF_Freaks_Trip_CIRCUS.clot_CIRCUS'
     Skins(0)=Combiner'KF_Specimens_Trip_CIRCUS_T.clot_CIRCUS.clot_CIRCUS_CMB'
}
