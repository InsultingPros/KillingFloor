// Zombie Monster for KF Invasion gametype
class ZombieBloatMix extends ZombieBloat;

simulated function BeginPlay()
{
	LinkSkelAnim(MeshAnimation'Bloat_anim');
	Super.BeginPlay();
}

defaultproperties
{
     KFRagdollName="FleshPound_Trip"
     Mesh=SkeletalMesh'KF_Freaks_Trip.FleshPound_Freak'
     Skins(0)=Combiner'KF_Specimens_Trip_T.fleshpound_cmb'
     Skins(1)=Shader'KFCharacters.FPAmberBloomShader'
}
