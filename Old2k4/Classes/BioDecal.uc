class BioDecal extends ProjectedDecal;

//#exec TEXTURE IMPORT NAME=xbiosplat FILE=TEXTURES\DECALS\BioDecala.tga LODSET=2 MODULATED=1 UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP
//#exec TEXTURE IMPORT NAME=xbiosplat2 FILE=TEXTURES\DECALS\BioDecalb.tga LODSET=2 MODULATED=1 UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP

simulated function BeginPlay()
{
	//KFTODO: Maybe replace this
    //if ( !Level.bDropDetail && (FRand() < 0.5) )
	//	ProjTexture = texture'xbiosplat2';
	Super.BeginPlay();
}

defaultproperties
{
     bClipStaticMesh=True
     CullDistance=7000.000000
     LifeSpan=6.000000
     DrawScale=0.650000
}
