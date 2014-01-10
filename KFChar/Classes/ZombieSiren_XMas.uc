//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieSiren_XMas extends ZombieSiren;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_Xmas.uax

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.caroler_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.caroler_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_XMAS_T.caroler_diffuse');
}

defaultproperties
{
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.siren.Siren_Jump'
     DetachedHeadClass=Class'KFChar.SeveredHeadSiren_XMas'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.siren.Siren_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.siren.Siren_Death'
     MenuName="Christmas Siren"
     Mesh=SkeletalMesh'KF_Freaks_Trip_Xmas.Caroler'
     Skins(1)=Shader'KF_Specimens_Trip_XMAS_T.Caroler.caroler_shdr'
}
