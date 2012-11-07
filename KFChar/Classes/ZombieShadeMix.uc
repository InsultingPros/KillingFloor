// Zombie Monster for KF Invasion gametype
class ZombieShadeMix extends ZombieShade;

simulated function BeginPlay()
{
	//LinkSkelAnim(MeshAnimation'InfectedWhiteMale1');
	Super.BeginPlay();
}

defaultproperties
{
     Skins(0)=Texture'KFCharacters.SirenSkin'
     Skins(1)=FinalBlend'KFCharacters.SirenHairFB'
}
