class HelloWordEmmiter extends ProjectedDecal;

var texture Splats[3];

simulated function PostBeginPlay()
{
    ProjTexture = splats[Rand(3)];
    Super.PostBeginPlay();
}

defaultproperties
{
     FOV=6
     bClipStaticMesh=True
     CullDistance=7000.000000
     LifeSpan=10.000000
}
