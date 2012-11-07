// Chainsaw Zombie Monster for KF Invasion gametype
// He's not quite as speedy as the other Zombies, But his attacks are TRULY damaging.
class ZombieScrakeMix extends ZombieScrake;

simulated function BeginPlay()
{
	LinkSkelAnim(MeshAnimation'Scrake_Anim');
	Super.BeginPlay();
}

defaultproperties
{
     KFRagdollName="Crawler_Trip"
     Mesh=SkeletalMesh'KF_Freaks_Trip.Crawler_Freak'
     DrawScale=1.300000
     PrePivot=(Z=-30.000000)
     Skins(0)=Combiner'KF_Specimens_Trip_T.crawler_cmb'
}
