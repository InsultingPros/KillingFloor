// Zombie Monster for KF Invasion gametype
class ZombieCrawlerMix extends ZombieCrawler;

simulated function BeginPlay()
{
	LinkSkelAnim(MeshAnimation'Crawler_Anim');
	Super.BeginPlay();
}

defaultproperties
{
     KFRagdollName="Siren_Trip"
     Mesh=SkeletalMesh'KF_Freaks_Trip.Siren_Freak'
     PrePivot=(Z=20.000000)
     Skins(0)=FinalBlend'KF_Specimens_Trip_T.siren_hair_fb'
     Skins(1)=Combiner'KF_Specimens_Trip_T.siren_cmb'
}
