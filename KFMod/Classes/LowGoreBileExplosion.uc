//=============================================================================
// Low gore Bloat bile explosion
//=============================================================================
// Killing Floor Source
// Copyright (C) 2009 Tripwire Interactive LLC
// Christian "schneidzekk" Schneider
//=============================================================================
class LowGoreBileExplosion extends FleshHitEmitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter103
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-500.000000)
         FadeOutStartTime=0.200000
         MaxParticles=2
         SizeScale(1)=(RelativeTime=0.070000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'kf_fx_trip_t.Gore.bloat_explode_blood_alt'
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=150.000000,Max=300.000000))
     End Object
     Emitters(0)=SpriteEmitter'KFMod.LowGoreBileExplosion.SpriteEmitter103'

     AutoDestroy=False
     LifeSpan=10.000000
     bUnlit=False
     bDirectional=True
}
