//=============================================================================
// GrenadeSmokeEffect
//=============================================================================
// Grenade Smoke Effect
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2006 Tripwire Interactive LLC
// - David Hensley & John "Ramm-Jaeger" Gibson
//=============================================================================

class GrenadeSmokeEffect extends Emitter;

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
         Acceleration=(X=10.000000,Y=10.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.600000
         FadeOutStartTime=2.560000
         FadeInEndTime=0.480000
         MaxParticles=30
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.050000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=4.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.Smoke.grenadesmoke'
         LifetimeRange=(Min=3.000000)
         StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=15.000000,Max=50.000000))
         VelocityLossRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.GrenadeSmokeEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-0.200000)
         ColorScale(0)=(Color=(B=128,G=128,R=128,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.800000
         FadeOutStartTime=40.000000
         FadeInEndTime=5.500000
         MaxParticles=2
         StartLocationRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=200.000000,Max=300.000000))
         SpinsPerSecondRange=(X=(Min=0.003000,Max=0.004000))
         StartSpinRange=(X=(Min=0.050000,Max=0.050000))
         SizeScale(0)=(RelativeSize=0.250000)
         SizeScale(1)=(RelativeTime=0.280000,RelativeSize=0.750000)
         SizeScale(2)=(RelativeTime=0.870000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=300.000000,Max=400.000000),Y=(Min=300.000000,Max=400.000000),Z=(Min=300.000000,Max=400.000000))
         InitialParticlesPerSecond=10.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.Smoke.grenadesmoke'
         LifetimeRange=(Min=45.000000,Max=50.000000)
         InitialDelayRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(Z=(Min=2.000000,Max=5.000000))
         VelocityLossRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000))
     End Object
     Emitters(1)=SpriteEmitter'ROEffects.GrenadeSmokeEffect.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-0.200000)
         ColorScale(0)=(Color=(B=128,G=128,R=128,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.800000
         FadeOutStartTime=50.400002
         FadeInEndTime=4.800000
         StartLocationRange=(X=(Min=-350.000000,Max=350.000000),Y=(Min=-350.000000,Max=350.000000),Z=(Max=100.000000))
         SpinsPerSecondRange=(X=(Min=0.003000,Max=0.004000))
         StartSpinRange=(X=(Min=-0.050000,Max=0.050000))
         SizeScale(0)=(RelativeSize=0.750000)
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=0.900000)
         SizeScale(2)=(RelativeTime=0.870000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=300.000000,Max=400.000000),Y=(Min=300.000000,Max=400.000000),Z=(Min=300.000000,Max=400.000000))
         InitialParticlesPerSecond=10.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.Smoke.grenadesmoke'
         LifetimeRange=(Min=55.000000,Max=60.000000)
         InitialDelayRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(Z=(Min=2.000000,Max=5.000000))
         VelocityLossRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000))
     End Object
     Emitters(2)=SpriteEmitter'ROEffects.GrenadeSmokeEffect.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(X=1.000000,Y=1.000000)
         ColorScale(0)=(Color=(B=128,G=128,R=128,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128,A=255))
         Opacity=0.900000
         FadeOutStartTime=6.000000
         FadeInEndTime=2.000000
         MaxParticles=70
         StartLocationRange=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=25.000000,Max=25.000000))
         SpinsPerSecondRange=(X=(Min=0.025000,Max=0.050000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=50.000000),Y=(Min=50.000000),Z=(Min=50.000000))
         InitialParticlesPerSecond=1.500000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.Smoke.grenadesmoke_fill'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=8.000000,Max=9.000000)
         InitialDelayRange=(Min=0.750000,Max=0.750000)
         StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000))
         VelocityLossRange=(X=(Min=0.150000,Max=0.150000),Y=(Min=0.150000,Max=0.150000),Z=(Min=0.100000,Max=0.100000))
     End Object
     Emitters(3)=SpriteEmitter'ROEffects.GrenadeSmokeEffect.SpriteEmitter3'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=80.000000
     Style=STY_Masked
     bHardAttach=True
     bDirectional=True
}
