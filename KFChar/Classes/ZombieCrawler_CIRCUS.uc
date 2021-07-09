//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ZombieCrawler_CIRCUS extends ZombieCrawler;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_CIRCUS.uax

static simulated function PreCacheMaterials(LevelInfo myLevel)
{//should be derived and used.
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_CIRCUS_T.crawler_CIRCUS.crawler_CIRCUS_CMB');
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Crawler.Crawler_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Crawler.Crawler_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Crawler.Crawler_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmCrawler_CIRCUS'
     DetachedLegClass=Class'KFChar.SeveredLegCrawler_CIRCUS'
     DetachedHeadClass=Class'KFChar.SeveredHeadCrawler_CIRCUS'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Crawler.Crawler_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Crawler.Crawler_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Crawler.Crawler_Acquire'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Crawler.Crawler_Acquire'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Crawler.Crawler_Acquire'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Crawler.Crawler_Acquire'
     MenuName="Circus Crawler"
     AmbientSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Crawler.Crawler_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip_CIRCUS.crawler_CIRCUS'
     Skins(0)=Combiner'KF_Specimens_Trip_CIRCUS_T.crawler_CIRCUS.crawler_CIRCUS_CMB'
}
