// Zombie Monster for KF Invasion gametype
class ZombieFleshPoundMix extends ZombieFleshPound;

simulated function BeginPlay()
{
	LinkSkelAnim(MeshAnimation'FleshPound_anim');
	Super.BeginPlay();
}

// changes colors on Device (notified in anim)
simulated function DeviceGoRed();
simulated function DeviceGoNormal();

defaultproperties
{
     KFRagdollName="GoreFast_Trip"
     Mesh=SkeletalMesh'KF_Freaks_Trip.GoreFast_Freak'
     Skins(0)=Combiner'KF_Specimens_Trip_T.gorefast_cmb'
}
