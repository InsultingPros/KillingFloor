// Zombie Monster for KF Invasion gametype
class ZombieClotMix extends ZombieClot;

simulated function BeginPlay()
{
	LinkSkelAnim(MeshAnimation'Clot_anim');
	Super.BeginPlay();
}

defaultproperties
{
     KFRagdollName="Stalker_Trip"
     Mesh=SkeletalMesh'KF_Freaks_Trip.Stalker_Freak'
     Skins(0)=Combiner'KF_Specimens_Trip_T.stalker_cmb'
     Skins(1)=FinalBlend'KF_Specimens_Trip_T.stalker_fb'
}
