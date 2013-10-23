class VomitDecalGlow extends ProjectedDecal;

#exec OBJ LOAD File=kf_fx_trip_t.utx

simulated function BeginPlay()
{
    if ( !Level.bDropDetail && (FRand() < 0.5) )
        ProjTexture = Texture'kf_fx_trip_t.Misc.Vomit_Splat_E';
    Super.BeginPlay();
}

defaultproperties
{
     ProjTexture=Texture'kf_fx_trip_t.Misc.Vomit_Splat_E'
     bClipStaticMesh=True
     CullDistance=7000.000000
     LifeSpan=5.000000
     DrawScale=0.500000
}
