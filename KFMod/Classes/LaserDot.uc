class LaserDot extends DynamicProjector;

simulated function ToggleDot()
{
     if( ProjTexture== default.ProjTexture )
     {
        ProjTexture = Texture'kf_fx_trip_t.Misc.Laser_Dot_Green';
     }
     else
     {
        ProjTexture = Texture'kf_fx_trip_t.Misc.Laser_Dot_Red';
     }
}

simulated function SetValid(bool bNewValid)
{
     if( bNewValid )
     {
        ProjTexture = Texture'kf_fx_trip_t.Misc.Laser_Dot_Green';
     }
     else
     {
        ProjTexture = Texture'kf_fx_trip_t.Misc.Laser_Dot_Red';
     }
}

defaultproperties
{
     MaterialBlendingOp=PB_Add
     FrameBufferBlendingOp=PB_Add
     ProjTexture=Texture'kf_fx_trip_t.Misc.Laser_Dot_Red'
     FOV=5
     MaxTraceDistance=100
     bClipBSP=True
     bProjectOnUnlit=True
     bGradient=True
     bProjectOnAlpha=True
     bProjectOnParallelBSP=True
     bNoProjectOnOwner=True
     DrawType=DT_None
     bLightChanged=True
     bHidden=False
     bSkipActorPropertyReplication=True
     RemoteRole=ROLE_SimulatedProxy
     DrawScale=0.250000
}
