class VomitDecal extends ProjectedDecal;

#exec OBJ LOAD File=KFX.utx

simulated function BeginPlay()
{
    if ( !Level.bDropDetail && (FRand() < 0.5) )
        ProjTexture = texture'VomSplat';
    Super.BeginPlay();
}

defaultproperties
{
     ProjTexture=Texture'KFX.VomSplat'
     bClipStaticMesh=True
     CullDistance=7000.000000
     LifeSpan=5.000000
     DrawScale=0.500000
}
