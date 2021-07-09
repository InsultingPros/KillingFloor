//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieFleshPound_CIRCUS extends ZombieFleshPound;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_CIRCUS.uax
#exec OBJ LOAD FILE=KF_Specimens_Trip_CIRCUS_T.utx

// changes colors on Device (notified in anim)
simulated function DeviceGoRed()
{
	Skins[0]= Shader'KF_Specimens_Trip_CIRCUS_T.pound_CIRCUS.pound_CIRCUS_Red_Shdr';
	Skins[1]= Shader'KFCharacters.FPRedBloomShader';
}

simulated function DeviceGoNormal()
{
	Skins[0] = Shader'KF_Specimens_Trip_CIRCUS_T.pound_CIRCUS.pound_CIRCUS_Amber_Shdr';
	Skins[1] = Shader'KFCharacters.FPAmberBloomShader';
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Shader'KF_Specimens_Trip_CIRCUS_T.pound_CIRCUS.pound_CIRCUS_Amber_Shdr');
	myLevel.AddPrecacheMaterial(Shader'KFCharacters.FPAmberBloomShader');
	myLevel.AddPrecacheMaterial(Shader'KF_Specimens_Trip_CIRCUS_T.pound_CIRCUS.pound_CIRCUS_Red_Shdr');
	myLevel.AddPrecacheMaterial(Shader'KFCharacters.FPRedBloomShader');
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmPound_CIRCUS'
     DetachedLegClass=Class'KFChar.SeveredLegPound_CIRCUS'
     DetachedHeadClass=Class'KFChar.SeveredHeadPound_CIRCUS'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     MenuName="Circus Flesh Pound"
     AmbientSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Fleshpound.FP_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip_CIRCUS.FleshPound_Circus'
     Skins(0)=Shader'KF_Specimens_Trip_CIRCUS_T.pound_CIRCUS.pound_CIRCUS_Amber_Shdr'
}
