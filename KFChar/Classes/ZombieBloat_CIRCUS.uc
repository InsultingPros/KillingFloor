//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieBloat_CIRCUS extends ZombieBloat;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_CIRCUS.uax

function PlayDyingSound()
{
	if ( Level.NetMode!=NM_Client )
	{
		if ( bGibbed )
		{
			PlaySound(sound'KF_EnemiesFinalSnd_Circus.Bloat_DeathPop', SLOT_Pain,2.0,true,525);
			return;
		}

		if ( bDecapitated )
		{
			PlaySound(HeadlessDeathSound, SLOT_Pain,1.30,true,525);
		}
		else
		{
			PlaySound(sound'KF_EnemiesFinalSnd_Circus.Bloat_DeathPop', SLOT_Pain,2.0,true,525);
		}
	}
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_CIRCUS_T.bloat_CIRCUS.bloat_clown_cmb');
}

defaultproperties
{
     BileExplosion=Class'KFMod.BileExplosion_Circus'
     BileExplosionHeadless=Class'KFMod.BileExplosionHeadless_Circus'
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Bloat.Bloat_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Bloat.Bloat_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Bloat.Bloat_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmBloat_CIRCUS'
     DetachedLegClass=Class'KFChar.SeveredLegBloat_CIRCUS'
     DetachedHeadClass=Class'KFChar.SeveredHeadBloat_CIRCUS'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Bloat.Bloat_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Bloat.Bloat_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Bloat.Bloat_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Bloat.Bloat_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Bloat.Bloat_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Bloat.Bloat_Challenge'
     MenuName="Circus Bloat"
     AmbientSound=Sound'KF_BaseBloat_CIRCUS.Bloat_Idle1Loop'
     Mesh=SkeletalMesh'KF_Freaks_Trip_CIRCUS.bloat_CIRCUS'
     Skins(0)=Combiner'KF_Specimens_Trip_CIRCUS_T.bloat_CIRCUS.bloat_clown_cmb'
}
