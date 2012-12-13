//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieHusk_XMas extends ZombieHusk;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_Xmas.uax
#exec OBJ LOAD FILE=KF_Specimens_Trip_XMAS_T_Two.utx

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_XMAS_T_Two.Husk_Snowman');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_XMAS_T_Two.husk_snowman_emiss');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T_Two.burns_energy_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T_Two.husk_snowman_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T_Two.husk_snowman_env_cmb');
	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_XMAS_T_Two.husk_snowman_shdr');
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_Xmas.Husk.Husk_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Bloat.Bloat_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Husk.Husk_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmHusk_XMas'
     DetachedLegClass=Class'KFChar.SeveredLegHusk_XMas'
     DetachedHeadClass=Class'KFChar.SeveredHeadHusk_XMas'
     DetachedSpecialArmClass=Class'KFChar.SeveredArmHusk_XMas'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Husk.Husk_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Husk.Husk_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Husk.Husk_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Husk.Husk_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Husk.Husk_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Husk.Husk_Challenge'
     MenuName="Christmas Husk"
     AmbientSound=Sound'KF_BaseHusk_Xmas.Husk_IdleLoop'
     Mesh=SkeletalMesh'KF_Freaks2_Trip_XMas.JackFrost'
     Skins(0)=Shader'KF_Specimens_Trip_XMAS_T_Two.Husk_Snowman.husk_snowman_shdr'
     Skins(1)=Shader'KF_Specimens_Trip_T_Two.burns.burns_shdr'
}
