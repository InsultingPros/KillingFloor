class ZombieFleshpound_STANDARD extends ZombieFleshpound;

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmPound'
     DetachedLegClass=Class'KFChar.SeveredLegPound'
     DetachedHeadClass=Class'KFChar.SeveredHeadPound'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     AmbientSound=Sound'KF_BaseFleshpound.FP_IdleLoop'
     Mesh=SkeletalMesh'KF_Freaks_Trip.FleshPound_Freak'
     Skins(0)=Combiner'KF_Specimens_Trip_T.fleshpound_cmb'
}
