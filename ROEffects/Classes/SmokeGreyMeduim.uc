class SmokeGreyMeduim extends ROLevelEmitters;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(X=25.000000,Z=100.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(A=255))
         FadeOutStartTime=2.960000
         FadeInEndTime=0.240000
         MaxParticles=100
         StartLocationOffset=(Z=150.000000)
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000))
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000))
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.520000)
         StartSizeRange=(X=(Max=225.000000),Y=(Max=225.000000),Z=(Max=225.000000))
         ParticlesPerSecond=2.000000
         InitialParticlesPerSecond=2.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.explosions.DSmoke_2'
         LifetimeRange=(Min=7.000000,Max=8.000000)
         StartVelocityRange=(X=(Min=-45.000000,Max=100.000000),Y=(Min=-45.000000,Max=100.000000),Z=(Min=50.000000,Max=250.000000))
         VelocityLossRange=(X=(Min=0.250000,Max=1.000000),Y=(Min=0.250000,Max=1.000000),Z=(Min=0.250000,Max=1.000000))
     End Object
     Emitters(0)=SpriteEmitter'ROEffects.SmokeGreyMeduim.SpriteEmitter0'

}
