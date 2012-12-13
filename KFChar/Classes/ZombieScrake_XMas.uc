//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieScrake_XMas extends ZombieScrake;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_Xmas.uax
#exec OBJ LOAD FILE=KF_BaseScrake_Xmas.uax
#exec OBJ LOAD FILE=KF_Specimens_Trip_XMAS_T.utx

simulated function SpawnExhaustEmitter()
{
}

simulated function UpdateExhaustEmitter()
{
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.Scrakefrost_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.scrake_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_XMAS_T.scrake_frost');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_XMAS_T.scrake_frost_opacity');
}

defaultproperties
{
     SawAttackLoopSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Scrake.Scrake_Chainsaw_Impale'
     ChainSawOffSound=Sound'KF_BaseScrake_Xmas.Chainsaw.Scrake_Chainsaw_Idle'
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_Xmas.Scrake.Scrake_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Scrake.Scrake_Chainsaw_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Scrake.Scrake_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmScrake_XMas'
     DetachedLegClass=Class'KFChar.SeveredLegScrake_XMas'
     DetachedHeadClass=Class'KFChar.SeveredHeadScrake_XMas'
     DetachedSpecialArmClass=Class'KFChar.SeveredArmScrakeSaw_XMas'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Scrake.Scrake_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Scrake.Scrake_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Scrake.Scrake_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Scrake.Scrake_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Scrake.Scrake_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Scrake.Scrake_Challenge'
     MenuName="Christmas Scrake"
     AmbientSound=Sound'KF_BaseScrake_Xmas.Chainsaw.Scrake_Chainsaw_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip_Xmas.ScrakeFrost'
     Skins(0)=Shader'KF_Specimens_Trip_XMAS_T.ScrakeFrost.scrake_frost_shdr'
}
