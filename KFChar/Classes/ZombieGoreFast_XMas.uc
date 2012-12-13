//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieGoreFast_XMas extends ZombieGorefast;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_Xmas.uax
#exec OBJ LOAD FILE=KF_Specimens_Trip_XMAS_T.utx

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.GingerFast.GingerFast_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.GingerFast_env_cmb');
	//myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_XMAS_T.GingerFast_cmb');
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmGorefast_XMas'
     DetachedLegClass=Class'KFChar.SeveredLegGorefast_XMas'
     DetachedHeadClass=Class'KFChar.SeveredHeadGorefast_XMas'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     MenuName="Christmas Gorefast"
     AmbientSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip_Xmas.GingerFast'
     Skins(0)=Combiner'KF_Specimens_Trip_XMAS_T.GingerFast.GingerFast_cmb'
}
