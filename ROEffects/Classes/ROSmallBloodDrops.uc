class ROSmallBloodDrops extends ProjectedDecal;

var texture Splats[3];

event PreBeginPlay()
{
	if ( Level.DetailMode > 1 )
	{
		CullDistance = CullDistance*3;
	}
	else if ( Level.DetailMode < 2 && Level.DetailMode > 0 )
	{
		CullDistance = CullDistance*1.5;
	}

	Super.PreBeginPlay();
}

simulated function PostBeginPlay()
{
    ProjTexture = splats[Rand(3)];
    Super.PostBeginPlay();
}

defaultproperties
{
     Splats(0)=Texture'Effects_Tex.GoreDecals.Drip_001'
     Splats(1)=Texture'Effects_Tex.GoreDecals.Drip_002'
     Splats(2)=Texture'Effects_Tex.GoreDecals.Drip_003'
     ProjTexture=Texture'Effects_Tex.GoreDecals.Drip_001'
     FOV=6
     bClipStaticMesh=True
     CullDistance=7000.000000
     LifeSpan=20.000000
     DrawScale=0.150000
}
