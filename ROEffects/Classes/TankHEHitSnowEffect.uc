//=============================================================================
// TankHEHitSnowEffect
//=============================================================================
// HE shell hitting snowy ground
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// Created by - David Hensely
// Coded in by - John "Ramm-Jaeger" Gibson
//=============================================================================

class TankHEHitSnowEffect extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         TriggerDisabled=False
         ResetOnTrigger=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.200000
         MaxParticles=4
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(X=1.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.140000,RelativeSize=3.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=7.000000)
         StartSizeRange=(X=(Min=30.000000,Max=50.000000),Y=(Min=30.000000,Max=50.000000),Z=(Min=45.000000,Max=50.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.explosions.LSmoke3'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=100.000000))
         VelocityLossRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.TankHEHitSnowEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         TriggerDisabled=False
         ResetOnTrigger=True
         Acceleration=(X=50.000000,Y=50.000000,Z=50.000000)
         ColorScale(0)=(Color=(B=128,G=128,R=128,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         MaxParticles=15
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(X=1.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=40.000000,Max=60.000000),Y=(Min=40.000000,Max=60.000000),Z=(Min=45.000000,Max=50.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.BulletHits.snowfinal2'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=3.000000,Max=6.000000)
         StartVelocityRange=(X=(Min=250.000000,Max=1500.000000),Y=(Min=-1000.000000,Max=1000.000000),Z=(Min=-1000.000000,Max=1000.000000))
         VelocityLossRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
     End Object
     Emitters(1)=SpriteEmitter'ROEffects.TankHEHitSnowEffect.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         TriggerDisabled=False
         ResetOnTrigger=True
         Acceleration=(Y=50.000000,Z=50.000000)
         ColorScale(0)=(Color=(B=91,G=91,R=91,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128,A=255))
         Opacity=0.750000
         FadeOutStartTime=0.990000
         FadeInEndTime=0.240000
         MaxParticles=15
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
         AddLocationFromOtherEmitter=1
         SpinCCWorCW=(X=1.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=25.000000,Max=35.000000),Y=(Min=25.000000,Max=35.000000),Z=(Min=45.000000,Max=50.000000))
         InitialParticlesPerSecond=50.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.BulletHits.snowfinal2'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=3.000000)
         InitialDelayRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=50.000000))
     End Object
     Emitters(2)=SpriteEmitter'ROEffects.TankHEHitSnowEffect.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=154,G=149,R=122,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(4)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.102500
         FadeInEndTime=0.050000
         MaxParticles=2
         SizeScale(1)=(RelativeTime=0.250000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000),Y=(Min=200.000000,Max=200.000000),Z=(Min=200.000000,Max=200.000000))
         InitialParticlesPerSecond=30.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.explosions.radialexplosion_1frame'
         LifetimeRange=(Min=0.250000,Max=0.250000)
     End Object
     Emitters(3)=SpriteEmitter'ROEffects.TankHEHitSnowEffect.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(X=50.000000,Y=50.000000,Z=0.500000)
         ColorScale(0)=(Color=(B=128,G=128,R=128,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=192,G=192,R=192,A=255))
         Opacity=0.750000
         FadeOutStartTime=0.990000
         MaxParticles=8
         StartLocationRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000))
         StartLocationShape=PTLS_Sphere
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=10.000000)
         StartSizeRange=(X=(Min=10.000000,Max=50.000000),Y=(Min=10.000000,Max=50.000000),Z=(Min=20.000000,Max=20.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.BulletHits.snowfinal2'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-700.000000,Max=700.000000),Y=(Min=-700.000000,Max=700.000000))
         VelocityLossRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
     End Object
     Emitters(4)=SpriteEmitter'ROEffects.TankHEHitSnowEffect.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         FadeOut=True
         RespawnDeadParticles=False
         UseRevolution=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=-1200.000000)
         DampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
         ColorScale(0)=(Color=(B=128,G=128,R=128,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=192,G=192,R=192,A=255))
         FadeOutStartTime=1.400000
         MaxParticles=15
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         StartSpinRange=(X=(Min=0.500000,Max=0.500000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartSizeRange=(X=(Min=1.000000,Max=3.000000),Y=(Min=1.000000,Max=3.000000),Z=(Min=3.000000,Max=5.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.BulletHits.snowchunksfinal'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=800.000000,Max=1000.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=-500.000000,Max=500.000000))
     End Object
     Emitters(5)=SpriteEmitter'ROEffects.TankHEHitSnowEffect.SpriteEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter6
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         Acceleration=(Z=50.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.102500
         FadeInEndTime=0.050000
         MaxParticles=2
         SizeScale(1)=(RelativeTime=0.140000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=30.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'Effects_Tex.explosions.impact_2frame'
         TextureUSubdivisions=2
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.300000,Max=0.300000)
         StartVelocityRange=(Z=(Min=10.000000,Max=10.000000))
     End Object
     Emitters(6)=SpriteEmitter'ROEffects.TankHEHitSnowEffect.SpriteEmitter6'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=8.000000
     Style=STY_Masked
     bHardAttach=True
     bDirectional=True
}