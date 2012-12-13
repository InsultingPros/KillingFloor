//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieClot_XMas extends ZombieClot;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_Xmas.uax
#exec OBJ LOAD FILE=KF_Specimens_Trip_XMAS_T.utx

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.Clot_Elf.Clot_Elf_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.clot_elf_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_XMAS_T.clot_elf_diff');
	//myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.clot_spec');
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_Xmas.clot.Clot_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.clot.Clot_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.clot.Clot_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmClot_XMas'
     DetachedLegClass=Class'KFChar.SeveredLegClot_XMas'
     DetachedHeadClass=Class'KFChar.SeveredHeadClot_XMas'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.clot.Clot_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.clot.Clot_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.clot.Clot_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_Xmas.clot.Clot_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_Xmas.clot.Clot_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_Xmas.clot.Clot_Challenge'
     MenuName="Christmas Clot"
     AmbientSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.clot.Clot_IdleLoop'
     Mesh=SkeletalMesh'KF_Freaks_Trip_Xmas.Clot_Elf'
     Skins(0)=Combiner'KF_Specimens_Trip_XMAS_T.Clot_Elf.Clot_Elf_cmb'
}
