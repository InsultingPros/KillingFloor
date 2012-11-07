class krivoi_smoke extends ROLevelEmitters;

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
         Acceleration=(Y=100.000000,Z=200.000000)
         ColorScale(0)=(Color=(R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=1.000000
         FadeInEndTime=1.000000
         MaxParticles=100
         StartLocationOffset=(Z=150.000000)
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000))
         SpinsPerSecondRange=(X=(Min=0.002500,Max=0.050000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=150.000000,Max=300.000000),Y=(Min=150.000000,Max=300.000000),Z=(Min=150.000000,Max=300.000000))
         ParticlesPerSecond=3.000000
         InitialParticlesPerSecond=3.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.explosions.DSmoke_1'
         LifetimeRange=(Min=10.000000,Max=10.000000)
         StartVelocityRange=(Z=(Min=200.000000,Max=400.000000))
         VelocityLossRange=(X=(Min=0.250000,Max=1.000000),Y=(Min=0.250000,Max=1.000000),Z=(Min=0.250000,Max=1.000000))
         WarmupTicksPerSecond=10.000000
         RelativeWarmupTime=10.000000
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.krivoi_smoke.SpriteEmitter0'

}
