//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieScrake_CIRCUS extends ZombieScrake;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_CIRCUS.uax
#exec OBJ LOAD FILE=KF_BaseScrake_CIRCUS.uax

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Shader'KF_Specimens_Trip_CIRCUS_T.scrake_CIRCUS.scrake_CIRCUS_shdr');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_CIRCUS_T.scrake_CIRCUS.scrake_CIRCUS_CMB');
	myLevel.AddPrecacheMaterial(Shader'KF_Specimens_Trip_T.scrake_FB');
	myLevel.AddPrecacheMaterial(TexPanner'KF_Specimens_Trip_T.scrake_saw_panner');
}

defaultproperties
{
     SawAttackLoopSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Scrake.Scrake_Chainsaw_Impale'
     ChainSawOffSound=Sound'KF_BaseScrake_CIRCUS.Chainsaw.Scrake_Chainsaw_Idle'
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Scrake.Scrake_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Scrake.Scrake_Chainsaw_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Scrake.Scrake_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmScrake_CIRCUS'
     DetachedLegClass=Class'KFChar.SeveredLegScrake_CIRCUS'
     DetachedHeadClass=Class'KFChar.SeveredHeadScrake_CIRCUS'
     DetachedSpecialArmClass=Class'KFChar.SeveredArmScrakeSaw'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Scrake.Scrake_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Scrake.Scrake_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Scrake.Scrake_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Scrake.Scrake_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Scrake.Scrake_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Scrake.Scrake_Challenge'
     MenuName="Circus Scrake"
     AmbientSound=Sound'KF_BaseScrake_CIRCUS.Chainsaw.Scrake_Chainsaw_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip_CIRCUS.scrake_CIRCUS'
     Skins(0)=Shader'KF_Specimens_Trip_CIRCUS_T.scrake_CIRCUS.scrake_CIRCUS_shdr'
     Skins(1)=Combiner'KF_Specimens_Trip_CIRCUS_T.scrake_CIRCUS.scrake_CIRCUS_CMB'
     Skins(2)=Shader'KF_Specimens_Trip_T.scrake_FB'
     Skins(3)=TexPanner'KF_Specimens_Trip_T.scrake_saw_panner'
}
