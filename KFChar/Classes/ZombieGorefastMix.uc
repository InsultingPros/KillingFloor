// Zombie Monster for KF Invasion gametype
// GOREFAST.
// He's speedy, and swings with a Single enlongated arm, affording him slightly more range
class ZombieGorefastMix extends ZombieGorefast;

simulated function BeginPlay()
{
	LinkSkelAnim(MeshAnimation'GoreFast_Anim');
	Super.BeginPlay();
}

defaultproperties
{
     KFRagdollName="Scrake_Trip"
     Mesh=SkeletalMesh'KF_Freaks_Trip.Scrake_Freak'
     Skins(0)=Shader'KF_Specimens_Trip_T.scrake_FB'
     Skins(1)=TexPanner'KF_Specimens_Trip_T.scrake_saw_panner'
}
