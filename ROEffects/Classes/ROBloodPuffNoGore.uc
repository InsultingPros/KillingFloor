//=============================================================================
// ROBloodPuffNoGore
//=============================================================================
// Blood puff for when a bullet hits a player in no gore settings
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// - David Hensley & John "Ramm-Jaeger" Gibson
//=============================================================================

class ROBloodPuffNoGore extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(B=55,G=70,R=81,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=55,G=70,R=81,A=255))
         Opacity=0.800000
         FadeOutStartTime=0.400000
         MaxParticles=3
         UseRotationFrom=PTRS_Actor
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=0.500000)
         SizeScale(1)=(RelativeTime=0.250000,RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.750000)
         StartSizeRange=(X=(Min=9.000000,Max=11.000000))
         InitialParticlesPerSecond=5000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.BulletHits.metalsmokefinal'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=0.800000,Max=0.800000)
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.ROBloodPuffNoGore.SpriteEmitter0'

     AutoDestroy=True
     bNoDelete=False
     bNetInitialRotation=True
     RemoteRole=ROLE_DumbProxy
     LifeSpan=1.500000
     Style=STY_Alpha
     bDirectional=True
}
