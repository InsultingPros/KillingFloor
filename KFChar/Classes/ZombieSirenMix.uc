// Zombie Monster for KF Invasion gametype
class ZombieSirenMix extends ZombieSiren;

simulated function BeginPlay()
{
	LinkSkelAnim(MeshAnimation'Siren_Anim');
	Super.BeginPlay();
}

defaultproperties
{
     KFRagdollName="Patriarch_Trip"
     Mesh=SkeletalMesh'KF_Freaks_Trip.Patriarch_Freak'
     Skins(0)=Combiner'KF_Specimens_Trip_T.gatling_cmb'
     Skins(1)=Combiner'KF_Specimens_Trip_T.patriarch_cmb'
}
