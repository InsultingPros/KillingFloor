//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieGoreFast_CIRCUS extends ZombieGorefast;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_CIRCUS.uax

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_CIRCUS_T.gorefast_CIRCUS.gorefast_CIRCUS_CMB');
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.GoreFast.Gorefast_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.GoreFast.Gorefast_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.GoreFast.Gorefast_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmGorefast_CIRCUS'
     DetachedLegClass=Class'KFChar.SeveredLegGorefast_CIRCUS'
     bHeadGibbed=True
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.GoreFast.Gorefast_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.GoreFast.Gorefast_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.GoreFast.Gorefast_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.GoreFast.Gorefast_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.GoreFast.Gorefast_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.GoreFast.Gorefast_Challenge'
     MenuName="Circus Gorefast"
     AmbientSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.GoreFast.Gorefast_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip_CIRCUS.gorefast_CIRCUS'
     Skins(0)=Combiner'KF_Specimens_Trip_CIRCUS_T.gorefast_CIRCUS.gorefast_CIRCUS_CMB'
}
