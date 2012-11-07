//=============================================================================
// ROBloodSplatter
//=============================================================================
// Blood splatter from someone getting shot
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
// Based off of the old XGame.BloodSplatter
//=============================================================================
class ROBloodSplatter extends ProjectedDecal;

var texture Splats[6];

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
    ProjTexture = splats[Rand(6)];
    Super.PostBeginPlay();
}

defaultproperties
{
     Splats(0)=Texture'Effects_Tex.GoreDecals.Splatter_001'
     Splats(1)=Texture'Effects_Tex.GoreDecals.Splatter_002'
     Splats(2)=Texture'Effects_Tex.GoreDecals.Splatter_003'
     Splats(3)=Texture'Effects_Tex.GoreDecals.Splatter_004'
     Splats(4)=Texture'Effects_Tex.GoreDecals.Splatter_005'
     Splats(5)=Texture'Effects_Tex.GoreDecals.Splatter_006'
     ProjTexture=Texture'Effects_Tex.GoreDecals.Splatter_001'
     FOV=6
     bClipStaticMesh=True
     LifeSpan=20.000000
     DrawScale=0.250000
}
